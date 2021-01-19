class GitController < ApplicationController
  before_action :create_repository_params, only: :create_repository
  before_action :delete_repository_params, only: :delete_repository
  before_action :favorite_repository_params, only: [:add_favorite_repository, :remove_favorite_repository]
  before_action :authenticate_user!


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
    git = GitManager::GitCreator.call(get_git_client, create_repository_params)
    create_repository = git.create_repository
    create_repository[:success] ? (render json: {success: 1}) : (render json: {error: 1, message: create_repository[:message]})
  end

  def delete_repository
    git = GitManager::GitCreator.call(get_git_client, delete_repository_params)
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
    user_id = favorite_repository_params[:user_id]
    repository_id = favorite_repository_params[:repo_id]
    user_repository = FavoriteRepository.where(user_id: user_id, repo_id: repository_id).exists?
    unless user_repository
      current_user.favorite_repositories.create(repo_id:repository_id)
    end

    render json: {success: 1}

  end

  def remove_favorite_repository
    user_id = favorite_repository_params[:user_id]
    repository_id = favorite_repository_params[:repo_id]
    user_repository = FavoriteRepository.where(user_id: user_id, repo_id: repository_id)
    user_repository.destroy_all

    render json: {success: 1}
  end

  private

  def create_repository_params
    begin
     param! :repo_name, String, blank: false, required: true, message: "Repository Name is required"
     param! :repo_name, String, min_length: 5, message: "The Repository Name is too short"
     param! :repo_type, String, in: %w(1 0), required: true,  message: "Please select repo type"
     params
    rescue => error
      render json: {
          error: 1,
          message: error.message
      }
    end

  end

  def delete_repository_params
    begin
     param! :repo_name, String, blank: false, required: true, message: "Repository Name is required"
     params
    rescue => error
      render json: {
          error: 1,
          message: error.message
      }
    end
  end


  def favorite_repository_params
    begin
      param! :user_id, Integer, blank: false, required: true, message: "User ID is required"
      param! :repo_id, Integer, blank: false, required: true, message: "Repo ID is required"
      params
    rescue => error
      render json: {
          error: 1,
          message: error.message
      }
    end
  end

end
