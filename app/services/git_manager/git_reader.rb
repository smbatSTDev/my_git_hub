
module GitManager


  class GitReader < ApplicationService

    def initialize(git_client, params = {})
      @client = git_client
      @params = params
    end


    def get_user_repositories
      repositories = @client.repos
    end

    def get_user_favorite_repositories
      user_id = @params[:user_id]
      user_repositories = FavoriteRepository.where(user_id: user_id).pluck(:repo_id)
      user_repositories
    end

    def search
      # TODO change searching limit for the user
      search_query = @params[:q]
      if @params[:page]
        page = @params[:page]
      else
        page = 1
      end

      repositories = @client.search_repositories search_query, {page: page}

      # create pagination data
      last_response = @client.last_response
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
    end

  end


end