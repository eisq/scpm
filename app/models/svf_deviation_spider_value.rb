class SvfDeviationSpiderValue < ActiveRecord::Base
	belongs_to 	:svf_deviation_spider_deliverable
	belongs_to 	:svf_deviation_question
end