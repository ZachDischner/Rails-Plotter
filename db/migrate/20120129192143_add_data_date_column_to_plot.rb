class AddDataDateColumnToPlot < ActiveRecord::Migration
  def change
    add_column :plots, :DataDate, :Datetime
  end
end
