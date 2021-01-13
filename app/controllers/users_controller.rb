class UsersController < Devise::RegistrationsController

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  # override this method to redirect /profile route when errors exist
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      set_flash_message_for_update(resource, prev_unconfirmed_email)
      bypass_sign_in resource, scope: resource_name if sign_in_after_change_password?
      respond_with resource, location: after_update_path_for(resource)
    else
      clean_up_passwords resource
      set_minimum_password_length
      flash[:errors] = resource.errors.full_messages
      redirect_to after_update_path_for(resource)
    end
  end

end
