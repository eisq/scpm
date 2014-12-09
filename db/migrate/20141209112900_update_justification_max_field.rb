class UpdateJustificationMaxField < ActiveRecord::Migration
	def self.up
	  	change_column :deviation_spider_consolidation_temps, :justification, :string, :limit => 1000
	end
	def self.down
    	change_column :deviation_spider_consolidation_temps, :justification, :string
  	end
end