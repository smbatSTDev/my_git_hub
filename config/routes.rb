Rails.application.routes.draw do
  devise_for :users, :controllers => {registrations: "users", :omniauth_callbacks => "callbacks"},
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


  # api routes
  namespace :api do
    scope :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
          sessions: 'v1/auth',
          registrations: 'v1/registration',
      }
    end
  end

end
