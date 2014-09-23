class DeviationSpider < ActiveRecord::Base
  	has_many    :deviation_spider_consolidations
  	has_many    :deviation_spider_deliverables
  	has_many	:deviation_spider_activity_values
  	has_many	:deviation_spider_deliverable_values
	belongs_to 	:milestone



	def init_spider_data

		activities 		= Array.new
		deliverables 	= Array.new
		# Check PSU
		deviation_spider_reference = self.milestone.project.get_current_deviation_spider_reference
		if deviation_spider_reference
			deviation_spider_reference.deviation_spider_settings.each do |setting|
				if !activities.include? setting.deviation_activity
					activities << setting.deviation_activity
				end 		

				# deliverable_parameter = DeviationDeliverable.find(:first, 
				                                                  # :joins=>["JOIN milestone_names ON milestone_names.id  = deviation_deliverables.milestone_name_id"], 
				                                                  # :conditions => ["milestone_names.title LIKE ? and id = ?","%#{self.milestone.name}%"])
			end
		end
		# Check base data

		# Check previous spiders

	end

end
