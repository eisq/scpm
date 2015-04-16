class UpdateSvtDeviationSpiderConsolidationTempsScore < ActiveRecord::Migration
	def self.up
	  	change_column :svt_deviation_spider_consolidation_temps, :score, :integer
	end
	def self.down
    	change_column :svt_deviation_spider_consolidation_temps, :score, :string
  	end
end