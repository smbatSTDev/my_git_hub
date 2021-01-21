class AddOmniauthToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :provider, :string, after: :birth_date
    add_column :users, :uid, :string, after: :provider
  end
end
