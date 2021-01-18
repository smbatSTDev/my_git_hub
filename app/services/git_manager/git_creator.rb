
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

    def add_favorite_repository
      # TODO create validation
      user_id = @params[:user_id]
      repository_id = @params[:repository_id]

      user_repository = FavoriteRepository.where(user_id: user_id, repo_id: repository_id).exists?

      unless user_repository
        favorite_repository = FavoriteRepository.new
        favorite_repository.user_id = user_id
        favorite_repository.repo_id = repository_id
        favorite_repository.save
        return true
      end

      false
    end

    def remove_favorite_repository
      # TODO create validation
      user_id = @params[:user_id]
      repository_id = @params[:repository_id]
      user_repository = FavoriteRepository.where(user_id: user_id, repo_id: repository_id)
      user_repository.destroy_all

      true
    end

  end

end