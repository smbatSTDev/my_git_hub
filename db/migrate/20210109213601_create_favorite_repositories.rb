class CreateFavoriteRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :favorite_repositories do |t|
      t.belongs_to :user, foreign_key: true, on_delete: :cascade
      t.integer :repo_id
      t.timestamps
    end
  end
end
