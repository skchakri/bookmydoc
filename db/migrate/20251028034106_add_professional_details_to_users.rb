class AddProfessionalDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :certificates, :text
    add_column :users, :awards, :text
    add_column :users, :bio, :text
    add_column :users, :rating, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :users, :testimonials_count, :integer, default: 0
  end
end
