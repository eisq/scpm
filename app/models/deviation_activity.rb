class DeviationActivity < ActiveRecord::Base
	has_many 	:deviation_spider_consolidations
	has_many 	:deviation_questions
  	has_many	:deviation_activity_deliverables
  	belongs_to  :deviation_meta_activity
end
