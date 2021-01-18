class GitController < ApplicationController
  before_action :validate_create_repository_params, only: :create_repository
  include GitManager

  def index

  end

  def new_repository

  end

  def get_user_repositories
    git = GitManager::GitReader.call(get_git_client)
    repositories = git.get_user_repositories
    render "git/repositories", locals: {repositories: repositories}
  end

  def create_repository
    git = GitManager::GitCreator.call(get_git_client, params)
    create_repository = git.create_repository
    create_repository[:success] ? (render json: {success: 1}) : (render json: {error: 1, message: create_repository[:message]})
  end

  def delete_repository
    git = GitManager::GitCreator.call(get_git_client, params)
    delete_repository = git.delete_repository
    delete_repository[:success] ? (render json: {success: 1}) : (render json: {error: 1, message: delete_repository[:message]})
  end

  def search
    git = GitManager::GitReader.call(get_git_client, params)
    repositories = git.search
    render json: repositories
  end

  def get_user_favorite_repositories
    user_id = params[:user_id]
    user_repository_ids = FavoriteRepository.where(user_id: user_id).pluck(:repo_id)
    render json: user_repository_ids
  end

  def add_favorite_repository
    # TODO create validation
    user_id = params[:user_id]
    repository_id = params[:repository_id]

    user_repository = FavoriteRepository.where(user_id: user_id, repo_id: repository_id).exists?
    unless user_repository
      current_user.favorite_repositories.create(repo_id:repository_id)
    end

    render json: {success: 1}

  end

  def remove_favorite_repository
    # TODO create validation
    user_id = params[:user_id]
    repository_id = params[:repository_id]
    user_repository = FavoriteRepository.where(user_id: user_id, repo_id: repository_id)
    user_repository.destroy_all

    render json: {success: 1}
  end

  def validate_create_repository_params
    if params.has_key?(:repo_name)
      if params[:repo_name] == ''
        render json: {
            error: 1,
            message: 'Repository name is required'
        }
      end
    end

  end

end
