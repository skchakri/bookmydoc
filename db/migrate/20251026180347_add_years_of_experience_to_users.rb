class AddYearsOfExperienceToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :years_of_experience, :integer
  end
end
