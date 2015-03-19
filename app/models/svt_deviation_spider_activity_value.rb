class SvtDeviationSpiderActivityValue < ActiveRecord::Base
	belongs_to 	:svt_deviation_activity
	belongs_to 	:svt_deviation_spider
end
