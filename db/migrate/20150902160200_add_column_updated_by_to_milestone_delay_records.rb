class AddColumnUpdatedByToMilestoneDelayRecords < ActiveRecord::Migration
	def self.up
		add_column :milestone_delay_records, :updated_by, :int
	end

	def self.down
		remove_column :milestone_delay_records, :updated_by
	end
end