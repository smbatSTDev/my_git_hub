class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validate :validate_git_access_token

  has_many :git_access_tokens
  has_many :favorite_repositories

  # custom validation
  def validate_git_access_token
    client = Octokit::Client.new(access_token: git_access_token)

    begin
      client.user
    rescue Octokit::Unauthorized
      errors.add(:base, "Invalid Git Access Token")
    end
  end
end
