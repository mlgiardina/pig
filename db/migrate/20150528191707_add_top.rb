class AddTop < ActiveRecord::Migration
  def change
    create_table :tops do |t|
      t.integer :wins, null: false
      t.string :name, null: false
    end
  end
end
