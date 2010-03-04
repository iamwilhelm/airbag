class ChangeDatatableAttributes < ActiveRecord::Migration
  class << self
    include AlterColumn
  end
 
  def self.up
    alter_column :datatables, :is_numeric, :boolean, { "1" => true, "else" => false }, true
    alter_column :datatables, :multiplier, :integer, "USING CAST(multiplier AS integer)", 1
    rename_column :datatables, :other_dims, :table_dim
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new
  end
end
