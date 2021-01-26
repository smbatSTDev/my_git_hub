module Validation

  class Validate

    def initialize(data, rules, messages = {})
      @data = data
      @messages = messages
      @error_messages = {}
      @rules_object = Rules.new(data)
      start_validation(rules, @data)
    end

    def start_validation(rules, data)
      new_data = {}

      data.each do |key, value|
        new_data[key.to_s] = value
      end

      rules.each do |key,rule|
        key = key.to_s
        if rule.is_a?(Hash)
          hashable_validate(new_data[key], rule, key)
        else
          split_and_validate(key, rule, new_data)
        end

      end
    end

    def is_valid?
      @error_messages.blank?
    end

    def errors
      @error_messages
    end

    def sieve_rules(rule)
      if rule[0..7] == 'in_array'
        return [rule[0..7], rule[9..-1]]
      else
        return [rule, nil]
      end
    end

    def hashable_validate(new_data, rules, checked_key)
      if new_data.is_a?(Array)
        new_data.each_with_index do |item, index|
          if item.is_a?(Hash)
            rules.each do |key, rule|
              if rule.is_a?(Hash)
                hashable_validate([item[key]],rule, key)
              else
                split_and_validate(key, rule, item)
              end
            end
          else
            @error_messages[checked_key] = "#{checked_key} Is not Hash"
          end
        end
      else
        @error_messages[checked_key] = "#{checked_key} Is not Array"
      end

    end

    def split_and_validate(key, value, new_data)

      split_rules = value.split('|')

      split_rules.each do |rule|

        rule, options = sieve_rules(rule)

        unless @rules_object.rules.include? rule
          raise "#{rule} - Rule Not Defined"
        end

        begin
          @rules_object.send(rule, {key: key, data:new_data, options:options})
        rescue ValidationException => error
          @error_messages[key] = error.message
          break
        end
      end

    end

  end

  class Rules

    def initialize(data)
      @data = data
    end

    def rules
      %w(required string email integer array in_array)
    end

    def required(**args)
      key = args[:key]
      data = args[:data]

      if data.key?(key)
        if data[key].blank?
          raise  ValidationException.new("#{key} - Is required")
        end
      else
        raise  ValidationException.new("#{key} - Is required")
      end
    end

    def email(**args)
      key = args[:key]
      data = args[:data]
      unless data[key].is_a?(String)
        raise  ValidationException.new("#{data[key]} - Is no correct email")
      end

      valid_email = data[key].match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)

      unless valid_email
        raise  ValidationException.new("#{data[key]} - Is no correct email")
      end
    end

    def string(**args)
      key = args[:key]
      data = args[:data]

      unless data[key].is_a?(String)
        raise  ValidationException.new("#{key} - Not valid String")
      end
    end

    def integer(**args)
      key = args[:key]
      data = args[:data]

      if data[key].is_a?(String)
        unless !!(data[key] =~ /\A[-+]?[0-9]+\z/)
          raise  ValidationException.new("#{data[key]} - Not valid Integer")
        end
      elsif !data[key].is_a?(Integer)
        raise  ValidationException.new("#{data[key]} - Not valid Integer")
      end
    end

    def array(**args)
      key = args[:key]
      data = args[:data]

      unless data[key].is_a?(Array)
        raise  ValidationException.new("#{data[key]} - Not valid Array")
      end
    end

    def in_array(**args)
      key = args[:key]
      data = args[:data]
      options = args[:options]

      # check if is a array
      array(args)

      keys_for_check = {}
      options.split(',').each do |keys_and_rules|
        nested_key = keys_and_rules.match(/(^[a-z]+)/)
        rules = keys_and_rules.match(/\(.+\)/).to_s
        rules[0] = ''
        rules[-1] = ''
        keys_for_check[nested_key[0]] = rules.split(';')
      end

      data[key].each_with_index do |item,index|
        keys_for_check.each do |ky,val|
          val.each do |j|
            self.send(j,{key:ky.to_s, data: item})
          end
        end
      end


    end


  end

  class ValidationException < StandardError
    def initialize(msg)
      @exception_type = 'data_validator_exception'
      super(msg)
    end
  end
end



