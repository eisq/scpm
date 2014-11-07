class DeviationSpiderDeliverableValue < ActiveRecord::Base
	belongs_to 	:deviation_deliverable
	belongs_to 	:deviation_spider
end
