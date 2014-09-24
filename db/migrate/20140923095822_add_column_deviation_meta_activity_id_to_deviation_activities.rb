class AddColumnDeviationMetaActivityIdToDeviationActivities < ActiveRecord::Migration

	def self.up
		add_column :deviation_activities, :deviation_meta_activity_id, :integer
	end

	def self.down
		remove_column :deviation_activities, :deviation_meta_activity_id
	end
end
