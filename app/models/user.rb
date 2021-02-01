class User < ApplicationRecord
  include DeviseTokenAuth::Concerns::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable, :omniauthable

  validate :validate_git_access_token

  has_many :git_access_tokens
  has_many :favorite_repositories

  # custom validation
  def validate_git_access_token
    begin
      if git_access_token?
        client = Octokit::Client.new(access_token: git_access_token)
        client.user
      end
    rescue Octokit::Unauthorized
      errors.add(:base, "Invalid Git Access Token")
    end
  end


  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
    end
  end
end
