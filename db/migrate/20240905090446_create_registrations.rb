class CreateRegistrations < ActiveRecord::Migration[7.1]
  def change
    create_table :registrations do |t|
      t.string :first_name
      t.string :last_name
      t.date :birthday
      t.string :gender
      t.string :email
      t.string :phone_number
      t.string :subject

      t.timestamps
    end
  end
end
