class RemoveNotNullDatatableAttributes < ActiveRecord::Migration
  def self.up
    change_column :datatables, :table_heading, :string, :limit => 255, :null => true
    change_column :datatables, :col_heading, :string, :limit => 255, :null => true
    change_column :datatables, :row_heading, :string, :limit => 255, :null => true
    change_column :datatables, :default_dim, :string, :default => "", :limit => 255, :null => true
    change_column :datatables, :is_numeric, :string, :limit => 255, :null => true
    change_column :datatables, :units, :string, :limit => 255, :null => true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
