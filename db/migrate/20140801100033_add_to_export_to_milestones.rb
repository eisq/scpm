class AddToExportToMilestones < ActiveRecord::Migration
  def self.up
    add_column :milestones, :to_export, :boolean, :default => false
  end

  def self.down
    remove_column :milestones, :is_virtual
  end
end

