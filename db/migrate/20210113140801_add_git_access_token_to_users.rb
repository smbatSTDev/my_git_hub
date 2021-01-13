class AddGitAccessTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :git_access_token, :string,after: :birth_date
  end
end
