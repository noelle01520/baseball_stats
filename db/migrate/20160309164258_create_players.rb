class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :position
      t.string :team_name
      t.string :team_city
      t.string :division
      t.string :league
      t.integer :year
      t.float :avg
      t.integer :home_runs
      t.integer :rbi
      t.integer :runs
      t.integer :stolen_bases
      t.float :ops

      t.timestamps null: false
    end
  end
end
