class RemoveUnwantedDatatableAttributes < ActiveRecord::Migration
  def self.up
    remove_column :datatables, :col_labels_one
    remove_column :datatables, :col_labels_two
    remove_column :datatables, :col_labels_content
    remove_column :datatables, :row_labels_one
    remove_column :datatables, :row_labels_two
    remove_column :datatables, :row_labels_content
    remove_column :datatables, :data_one
    remove_column :datatables, :data_two
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
