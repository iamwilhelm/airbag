class AddLicenseToDatatable < ActiveRecord::Migration
  def self.up
    add_column :datatables, :license, :string, :limit => 50, :default => "public domain"
  end

  def self.down
    remove_column :datatables, :license
  end
end
