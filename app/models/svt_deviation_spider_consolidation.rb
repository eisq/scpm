class SvtDeviationSpiderConsolidation < ActiveRecord::Base
	belongs_to 	:svt_deviation_activity
	belongs_to 	:svt_deviation_deliverable
	belongs_to 	:svt_deviation_spider
end
