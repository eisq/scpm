class SvfDeviationSpiderActivityValue < ActiveRecord::Base
	belongs_to 	:svf_deviation_activity
	belongs_to 	:svf_deviation_spider
end