class SvfDeviationSpiderDeliverableValue < ActiveRecord::Base
	belongs_to 	:svf_deviation_deliverable
	belongs_to 	:svf_deviation_spider
end