class SvtDeviationSpiderDeliverableValue < ActiveRecord::Base
	belongs_to 	:svt_deviation_deliverable
	belongs_to 	:svt_deviation_spider
end
