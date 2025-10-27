class CreateAwards < ActiveRecord::Migration[7.1]
  def change
    create_table :awards do |t|
      t.references :doctor, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.string :issuing_organization
      t.date :date_received
      t.text :description

      t.timestamps
    end

  end
end
