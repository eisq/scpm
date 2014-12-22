class DeviationSpiderConsolidationTemp < ActiveRecord::Base
	belongs_to 	:deviation_activity
	belongs_to 	:deviation_deliverable
	belongs_to 	:deviation_spider
end
