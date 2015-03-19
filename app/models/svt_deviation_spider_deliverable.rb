class SvtDeviationSpiderDeliverable < ActiveRecord::Base
	belongs_to 	:svt_deviation_spider
	belongs_to 	:svt_deviation_deliverable
	has_many    :svt_deviation_spider_values
end
