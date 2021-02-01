class V1::RegistrationController < DeviseTokenAuth::RegistrationsController
  skip_before_action :verify_authenticity_token
  include DeviseTokenAuth::Concerns::SetUserByToken


end
