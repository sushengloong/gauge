class CreateGoals < ActiveRecord::Migration
  def change
    create_table :goals do |t|
      t.string :name
      t.decimal :amount
      t.date :due_date

      t.timestamps
    end
  end
end
