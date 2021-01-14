Rails.application.routes.draw do
  devise_for :users, :controllers => {registrations: "users"},
             :path => '', :path_names => {  edit: 'profile' }

  root 'home#index'

  # git
  get 'git-search-result', to: 'git#index', as: 'search_page'
  get 'git-search', to: 'git#search', as: 'search'

  # git repositories
  get 'repositories', to: 'git#get_user_repositories', as: 'user_repositories'
  get 'new-repository', to: 'git#new_repository', as: 'create_repository'
  post 'create-repository', to: 'git#create_repository'
  delete 'repository', to: 'git#delete_repository'
  get 'favorite-repositories/:user_id', to: 'git#get_user_favorite_repositories', as: 'user_favorite_repositories'
  post 'add-favorite-repository', to: 'git#add_favorite_repository'
  post 'remove-favorite-repository', to: 'git#remove_favorite_repository'

end
