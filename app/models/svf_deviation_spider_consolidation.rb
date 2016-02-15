class SvfDeviationSpiderConsolidation < ActiveRecord::Base
	belongs_to 	:svf_deviation_activity
	belongs_to 	:svf_deviation_deliverable
	belongs_to 	:svf_deviation_spider
end