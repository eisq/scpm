class AddColumnProjectIdToMilestoneDelayRecords < ActiveRecord::Migration
	def self.up
		add_column :milestone_delay_records, :project_id, :int
	end

	def self.down
		remove_column :milestone_delay_records, :project_id
	end
end