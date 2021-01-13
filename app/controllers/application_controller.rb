class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    search_page_path
  end


  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:gender, :birth_date, :git_access_token])
  end



end
