class AddColumnDateTypeToMilestoneDelayRecords < ActiveRecord::Migration
	def self.up
		add_column :milestone_delay_records, :date_type, :text
	end

	def self.down
		remove_column :milestone_delay_records, :date_type
	end
end