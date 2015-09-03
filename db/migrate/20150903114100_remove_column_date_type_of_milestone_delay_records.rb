class RemoveColumnDateTypeOfMilestoneDelayRecords < ActiveRecord::Migration
  def self.up
  	remove_column :milestone_delay_records, :date_type
  end

  def self.down
	add_column :milestone_delay_records, :date_type, :text
  end
end
