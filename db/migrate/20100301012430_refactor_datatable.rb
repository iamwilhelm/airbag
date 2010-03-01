class RefactorDatatable < ActiveRecord::Migration
  def self.up
    rename_column :datatables, :table_heading, :name
    rename_column :datatables, :descr, :description
    
    remove_column :datatables, :col_heading
    remove_column :datatables, :row_heading
    remove_column :datatables, :converter
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
