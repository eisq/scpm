class AddIndexToDeviationMetaActivities < ActiveRecord::Migration

	def self.up
		add_column :deviation_meta_activities, :index, :integer
	end

	def self.down
		remove_column :deviation_meta_activities, :index
	end
end
