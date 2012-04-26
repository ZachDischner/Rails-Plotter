class ChangeColumn < ActiveRecord::Migration
  def up
    change_column :plots, :x, :float
  end

  def down
    change_column :plots, :x, :integer
  end
end
