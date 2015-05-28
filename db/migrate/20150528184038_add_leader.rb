class AddLeader < ActiveRecord::Migration
  def change
    create_table :leaders do |t|
      t.integer :scores
      t.string :names
    end
  end
end
