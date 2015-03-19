class SvtDeviationSpiderValue < ActiveRecord::Base
	belongs_to 	:svt_deviation_spider_deliverable
	belongs_to 	:svt_deviation_question
end
