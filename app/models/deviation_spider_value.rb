class DeviationSpiderValue < ActiveRecord::Base
	belongs_to 	:deviation_spider_deliverable
	belongs_to 	:deviation_question
end
