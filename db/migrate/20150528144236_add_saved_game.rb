class AddSavedGame < ActiveRecord::Migration
  def change
    create_table :saved_games do |t|
      t.string :names
      t.string :scores
    end
  end
end
