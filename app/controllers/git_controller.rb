class GitController < ApplicationController
  def index

  end

  def search
    # TODO change searching limit for the user
    # TODO auth 1 time

    client = Octokit::Client.new(access_token: ENV['GIT_ACCESS_TOKEN'])
    search_query = params[:q]
    if params[:page]
      page = params[:page]
    else
      page = 1
    end

    repositories = client.search_repositories search_query, {page: page}

    # create pagination data
    last_response = client.last_response
    last_page = last_response.rels[:last]? last_response.rels[:last].href.match(/page=(\d+).*$/)[1] : nil
    next_page = last_response.rels[:next]? last_response.rels[:next].href.match(/page=(\d+).*$/)[1] : nil
    previous = last_response.rels[:prev]? last_response.rels[:prev].href.match(/page=(\d+).*$/)[1] : nil
    total_count = last_response.rels[:last]? last_response.rels[:last].href.match(/page=(\d+).*$/)[1].to_i * 30 : nil
    response = {
        last_page: last_page,
        next_page: next_page,
        previous: previous,
        total_count: total_count,
        repositories: repositories
    }

    render json: response
  end

  def add_favorite_repository
    # TODO create validation
    user_id = params[:user_id]
    repository_id = params[:repository_id]

    user_repository = FavoriteRepository.where(user_id: user_id, repo_id: repository_id).exists?

    unless user_repository
      favorite_repository = FavoriteRepository.new
      favorite_repository.user_id = user_id
      favorite_repository.repo_id = repository_id
      favorite_repository.save
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

  def get_user_favorite_repositories

    user_id = params[:user_id]

    user_repositories = FavoriteRepository.where(user_id: user_id).pluck(:repo_id)

    render json: user_repositories
  end

end
