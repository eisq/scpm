class AddColumnCurrentQualityStatusToMilestones < ActiveRecord::Migration

	def self.up
		add_column :milestones, :current_quality_status, :text
	end

	def self.down
		remove_column :milestones, :current_quality_status
	end
end