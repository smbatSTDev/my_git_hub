class V1::AuthController < DeviseTokenAuth::SessionsController
  skip_before_action :verify_authenticity_token
  include DeviseTokenAuth::Concerns::SetUserByToken


end
