class UpdateDeviationSpiderSvtFromTrueToFalse < ActiveRecord::Migration

	def self.up
		change_column :projects, :deviation_spider_svt, :boolean, :default=>false
	end

	def self.down
		change_column :projects, :deviation_spider_svt, :boolean, :default=>true
	end
end
