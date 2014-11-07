class UpdateDeviationSpiderFromTrueToFalse < ActiveRecord::Migration

	def self.up
		change_column :projects, :deviation_spider, :boolean, :default=>false
	end

	def self.down
		change_column :projects, :deviation_spider, :boolean, :default=>true
	end
end
