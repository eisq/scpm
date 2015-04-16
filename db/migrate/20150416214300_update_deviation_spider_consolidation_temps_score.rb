class UpdateDeviationSpiderConsolidationTempsScore < ActiveRecord::Migration
	def self.up
	  	change_column :deviation_spider_consolidation_temps, :score, :integer
	end
	def self.down
    	change_column :deviation_spider_consolidation_temps, :score, :string
  	end
end