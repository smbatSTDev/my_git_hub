class AddGenderAndBirthDateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :gender, :string, after: :email
    add_column :users, :birth_date, :date, after: :gender
  end
end
