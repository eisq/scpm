class AddIsActiveToMilestoneNames < ActiveRecord::Migration
  def self.up
    add_column :milestone_names, :is_active, :boolean, :default => true
  end

  def self.down
    remove_column :milestone_names, :is_active
  end
end

