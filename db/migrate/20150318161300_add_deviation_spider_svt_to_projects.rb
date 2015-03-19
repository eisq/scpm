class AddDeviationSpiderSvtToProjects < ActiveRecord::Migration

	def self.up
		add_column :projects, :deviation_spider_svt, :boolean, :default=>true
	end

	def self.down
		remove_column :projects, :deviation_spider_svt
	end
end