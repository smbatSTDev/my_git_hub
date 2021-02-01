class AddOmniauthToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :provider, :string, after: :birth_date, default: 'email'
    add_column :users, :uid, :string, after: :provider
    add_index :users, [:uid, :provider], unique: true
  end
end
