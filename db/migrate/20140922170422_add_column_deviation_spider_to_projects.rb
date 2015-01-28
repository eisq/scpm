class AddColumnDeviationSpiderToProjects < ActiveRecord::Migration

	def self.up
		add_column :projects, :deviation_spider, :boolean, :default=> true
	end

	def self.down
		remove_column :projects, :deviation_spider
	end
end
