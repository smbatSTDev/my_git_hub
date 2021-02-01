class AddDeviseTokenAuthToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tokens, :text, after: :uid
    add_column :users, :confirmation_token, :string, after: :tokens
    add_column :users, :confirmed_at, :datetime, default: Time.now, after: :confirmation_token
    add_column :users, :confirmation_sent_at, :datetime, after: :confirmed_at
    add_column :users, :unconfirmed_email, :string, after: :confirmation_sent_at
    add_index :users, :confirmation_token,   unique: true
  end
end
