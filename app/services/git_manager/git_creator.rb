
module GitManager

  class GitCreator < ApplicationService

    def initialize(git_client, params = {})
      @client = git_client
      @params = params
    end

    def create_repository
      repository_name = @params[:repo_name]
      repository_type = @params[:repo_type]

      if repository_type == '1'
        is_private = true
      else
        is_private = false
      end

      begin
        @client.create_repository repository_name, {private: is_private}
        {success: true}
      rescue => error
        {success: false, message: error.message}
      end

    end

    def delete_repository
      repo_name = @params[:repo_name]

      begin
        @client.delete_repository repo_name
        {success: true}
      rescue => error
        {success: false, message: error.message}
      end

    end

  end

end