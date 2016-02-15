class SvfDeviationSpiderDeliverable < ActiveRecord::Base
	belongs_to 	:svf_deviation_spider
	belongs_to 	:svf_deviation_deliverable
	has_many    :svf_deviation_spider_values
end