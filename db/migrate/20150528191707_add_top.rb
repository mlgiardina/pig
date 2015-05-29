class AddTop < ActiveRecord::Migration
  def change
    create_table :tops do |t|
      t.integer :wins
      t.string :name
    end
  end
end
