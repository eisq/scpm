class AddIsActiveToLifecycles < ActiveRecord::Migration
  def self.up
    add_column :lifecycles, :is_active, :boolean, :default => true
  end

  def self.down
    remove_column :lifecycles, :is_active
  end
end
