class AddProjectIdToSvtDeviationSpiders < ActiveRecord::Migration

	def self.up
		add_column :svt_deviation_spiders, :project_id, :int
	end

	def self.down
		remove_column :svt_deviation_spiders, :project_id
	end
end