class UpdateDeviationSpiderSvfFromTrueToFalse < ActiveRecord::Migration

	def self.up
		change_column :projects, :deviation_spider_svf, :boolean, :default=>false
	end

	def self.down
		change_column :projects, :deviation_spider_svf, :boolean, :default=>true
	end
end