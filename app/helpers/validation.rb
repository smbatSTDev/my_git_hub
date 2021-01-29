module Validation

  class Validate

    def initialize(data, rules, messages = {})
      @data = data
      @messages = messages
      @rules_object = Rules.new(data)
      start_validation(rules, @data)
    end

    def start_validation(rules, data)
      rules.each do |key, rule|
        main_key = key
        @rules_object.validate(key, rule, data, main_key)
      end

    end

    def is_valid?
      @rules_object.errors.blank?
    end

    def errors
      @rules_object.errors
    end

  end

  class Rules

    def initialize(data)
      @data = data
      @error_messages = {}
    end

    def errors
      @error_messages
    end

    def validate(key, rules, data, main_key = nil, index = nil)
      # convert rules keys to strings
      rules = rules.transform_keys(&:to_sym)
      data = data.transform_keys(&:to_sym)
      # skip all rules if required is false and data is nil

      if !rules[:required] and data[key].nil?
        return
      end

      unless rules.key?(:required)
        rules[:required] = false
      end

      # first check required or not
      if rules[:required]
        begin
          required({key: key, data: data, value: true})
          # remove required rule after success validation
          rules.delete(:required)
        rescue ValidationException => error
          if main_key and index
            key = main_key.to_s + '_' + index.to_s
          end
          if @error_messages.key?(key)
            @error_messages[key] = @error_messages[key] + ', ' + error.message
          else
            @error_messages[key] = error.message
          end
          return
        end
      end


      rules.each do |rule, value|

        next if ignore_rules.include? rule.to_s

        unless allowed_rules.include? rule.to_s
          raise "#{rule} - Rule Not Defined"
        end

        begin
          if main_key.to_s != key.to_s and index
            overwrite_main_kay = main_key.to_s + '_' + index.to_s + '_' + key.to_s
          else
            overwrite_main_kay = main_key
          end
          self.send(rule, {key: key, main_key: overwrite_main_kay, data: data, value: value, rules: rules})
        rescue ValidationException => error
          if main_key and index
            key = main_key.to_s + '_' + index.to_s
          end
          if @error_messages.key?(key)
            @error_messages[key] = @error_messages[key] + ', ' + error.message
          else
            @error_messages[key] = error.message
          end
          break
        end
      end
      @error_messages
    end

    def allowed_rules
      %w(required string email integer array type hashable)
    end

    def ignore_rules
      %w(hash_properties items_type)
    end

    def type(**args)

      # convert args keys to strings
      args = args.transform_keys(&:to_sym)
      value = args[:value]

      if value
        rule = value.name.downcase
        if rule == 'hash'
          rule = 'hashable'
        end

        unless allowed_rules.include? rule
          raise "#{rule} - Rule Not Defined"
        end

        self.send(rule, args)
      end

    end

    def required(**args)
      value = args[:value]
      key = args[:key]
      data = args[:data]
      if value
        if data.key?(key)
          if data[key].nil?
            raise ValidationException.new("#{key} - Is required")
          end
        else
          raise ValidationException.new("#{key} - Is required")
        end
      end
    end

    def email(**args)
      key = args[:key]
      data = args[:data]

      unless data[key].is_a?(String)
        raise ValidationException.new("#{data[key]} - Is no correct email")
      end

      valid_email = data[key].match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)

      unless valid_email
        raise ValidationException.new("#{data[key]} - Is no correct email")
      end
    end

    def string(**args)
      key = args[:key]
      data = args[:data]

      unless data[key].is_a?(String)
        raise ValidationException.new("#{data[key]} - Not valid String")
      end
    end

    def integer(**args)
      key = args[:key]
      data = args[:data]

      if data[key].is_a?(String)
        unless !!(data[key] =~ /\A[-+]?[0-9]+\z/)
          raise ValidationException.new("#{data[key]} - Not valid Integer")
        end
      elsif !data[key].is_a?(Integer)
        raise ValidationException.new("#{data[key]} - Not valid Integer")
      end
    end

    def array(**args)
      key = args[:key]
      data = args[:data]
      rules = args[:rules]

      unless data[key].is_a?(Array)
        raise ValidationException.new("#{data[key]} - Not valid Array")
      end

      if rules.key?(:items_type)
        unless ignore_rules.include? 'items_type'
          raise "hash_properties - Rule Not Defined In ignored rules"
        end
        # check type of items in array
        array_of(args)
      end

      if rules.key?(:hash_properties)
        unless ignore_rules.include? 'hash_properties'
          raise "hash_properties - Rule Not Defined In ignored rules"
        end
        # check keys and values of hashes in array
        array_hash_validation(args)
      end

    end

    def hashable(**args)
      key = args[:key]
      data = args[:data]

      unless data[key].is_a?(Hash)
        raise ValidationException.new("#{data[key]} - Not valid Hash")
      end
    end

    def array_hash_validation(**args)

      key = args[:key]
      data = args[:data]
      hash_properties = args[:rules][:hash_properties]

      main_key = args[:main_key]

      data[key].each_with_index do |item, index|
        hash_properties.each do |key, rules|
          validate(key, rules, item, main_key, index)
        end
      end
    end

    def array_of(**args)
      key = args[:key]
      data = args[:data]
      item_type = args[:rules][:items_type]

      if data[key].blank?
        raise ValidationException.new("#{data[key]} has no #{item_type} items")
      end

      # not rise exception here
      data[key].each_with_index do |item, index|
        unless item.is_a?(item_type)
          @error_messages[args[:main_key].to_s + '_' + index.to_s] = "# #{item} - Not valid  #{item_type}"
        end
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

      data[key].each_with_index do |item, index|
        keys_for_check.each do |ky, val|
          val.each do |j|
            self.send(j, {key: ky.to_s, data: item})
          end
        end
      end


    end

    # def hashable_valid(new_data, data_params, checked_key)
    #
    #   abort
    #   syntax_error_message = "#{checked_key} should have a key like  type: [Array, Hash].\nFirst item should be a type of #{checked_key}, second type of items.\n If first param is a Hash second not required"
    #
    #   if data_params.key?(:type)
    #     type_of_data = data_params[:type][0]
    #     items_in_data = data_params[:type][1]
    #
    #     if type_of_data.nil? or items_in_data.nil?
    #       @error_messages[:syntax_error] = syntax_error_message
    #     else
    #       if type_of_data.is_a?(Array)
    #
    #       end
    #     end
    #   else
    #     @error_messages[:syntax_error] = syntax_error_message
    #   end


    # end

  end

  class ValidationException < StandardError
    def initialize(msg)
      @exception_type = 'data_validator_exception'
      super(msg)
    end
  end
end



