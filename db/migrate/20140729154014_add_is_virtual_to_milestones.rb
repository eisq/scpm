class AddIsVirtualToMilestones < ActiveRecord::Migration
  def self.up
    add_column :milestones, :is_virtual, :boolean, :default => true
  end

  def self.down
    remove_column :milestones, :is_virtual
  end
end
