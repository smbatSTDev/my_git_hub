Rails.application.routes.draw do
  devise_for :users

  root 'home#index'
  get 'git-search-result', to: 'git#index', as: 'search_page'
  get 'git-search', to: 'git#search', as: 'search'
  get 'favorite-repositories/:user_id', to: 'git#get_user_favorite_repositories', as: 'user_favorite_repositories'
  post 'add-favorite-repository', to: 'git#add_favorite_repository'
  post 'remove-favorite-repository', to: 'git#remove_favorite_repository'



end
