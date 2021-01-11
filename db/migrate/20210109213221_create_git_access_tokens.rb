class CreateGitAccessTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :git_access_tokens do |t|
      t.belongs_to :user, foreign_key: true, on_delete: :cascade
      t.string :access_token, unique: true
      t.timestamps
    end
  end
end
