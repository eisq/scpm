class AddProjectIdToDeviationSpiders < ActiveRecord::Migration

	def self.up
		add_column :deviation_spiders, :project_id, :int
	end

	def self.down
		remove_column :deviation_spiders, :project_id
	end
end