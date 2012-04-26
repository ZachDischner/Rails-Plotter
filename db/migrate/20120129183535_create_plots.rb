class CreatePlots < ActiveRecord::Migration
  def change
    create_table :plots do |t|
      t.integer :x
      t.float :y1
      t.float :y2

      t.timestamps
    end
  end
end
