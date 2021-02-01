class V1::ApiApplicationController < ApplicationController
  include DeviseTokenAuth::Concerns::SetUserByToken
  skip_before_action :verify_authenticity_token
end
