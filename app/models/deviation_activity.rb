class DeviationActivity < ActiveRecord::Base
	has_many 	:deviation_spider_consolidations
	has_many 	:deviation_questions
  	has_many	:deviation_activity_deliverables
  	belongs_to  :deviation_meta_activity


  	def has_deliverable?(deliverable_id)
  		deliverable_count = deviation_activity_deliverables.count(:conditions => ["deviation_deliverable_id = ?", deliverable_id])
  		return deliverable_count > 0
  	end
end
