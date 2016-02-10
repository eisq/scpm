class AddDeviationSpiderSvfToProjects < ActiveRecord::Migration

	def self.up
		add_column :projects, :deviation_spider_svf, :boolean, :default=>true
	end

	def self.down
		remove_column :projects, :deviation_spider_svf
	end
end