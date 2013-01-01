class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.decimal :amount
      t.text :note
      t.string :repeat
      t.datetime :trans_date
      t.integer :category_id

      t.timestamps
    end
  end
end
