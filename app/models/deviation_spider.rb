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
				activity_parameter = DeviationAcitivity.find(:first, :conditions => ["name LIKE ?","%#{setting.activity_name}%"])
				if !activities.include? activity_parameter
					activities << activity_parameter
				end 		

				deliverable_parameter = DeviationDeliverable.find(:first, 
				                                                  :joins=>["JOIN milestone_names ON milestone_names.id  = deviation_deliverables.milestone_name_id"], 
				                                                  :conditions => ["milestone_names.title LIKE ? and name LIKE ?","%#{self.milestone.name}%","%#{setting.deliverable_name}%"])

				if !deliverables.include? deliverable_parameter
					activities << deliverable_parameter
				end 
			end
		else
			all_deliverables = DeviationDeliverable.find(:all,:joins=>["JOIN milestone_names ON milestone_names.id  = deviation_deliverables.milestone_name_id"],:conditions => ["milestone_names.title LIKE ?","%#{self.milestone.name}%"])
			deliverables = all_deliverables
			all_activities = DeviationActivity.find(:all)
			activities = all_activities
		end


		# Create data
		deliverables.each do |deliverable|
			add_deliverable(deliverable, activities)
		end


		# Check last milestone
		project_milestones = self.milestone.project.sorted_milestones.select { |m| m.is_eligible_for_spider? and m.name[0..1]!='QG' and m.is_virtual == false }
		i = 0
		self_index = -1
		project_milestones.each do |sorted_milestone|
			if sorted_milestone.id == self.milestone.id
				self_index = i
			end
			i = i + 1
		end	

		# If the self milestone was found and it's not the first
		if self_index > 0
			previous_milestone = project_milestones[self_index-1]
			last_spider = DeviationSpider.find(:first, :joins=>["JOIN deviation_spider_consolidations ON deviation_spiders.id  = deviation_spider_consolidations.deviation_spider_id"], :conditions =>["milestone_id = ?", previous_milestone.id] )

			# Check for each deliverable if one question is to false, if this is the case, we add the deliverable.
			if last_spider != nil

				last_spider.deviation_spider_deliverables.each do |spider_deliverable|
					deliverable_not_completed = false
					spider_deliverable.deviation_spider_values.each do |spider_value|
						if !spider_value.answer
							deliverable_not_completed = true
						end
						break if deliverable_not_completed
					end

					if deliverable_not_completed and !deliverables.include? spider_deliverable
						add_deliverable(spider_deliverable.deviation_deliverable, activities)
					end

				end
			end
		end
	end

	def add_deliverable(deliverable, activities)
		new_spider_deliverable = DeviationSpiderDeliverable.new
		new_spider_deliverable.deviation_spider_id = self.id
		new_spider_deliverable.deviation_deliverable_id = deliverable.id
		new_spider_deliverable.save

		activities.each do |activity|
			questions = DeviationQuestion.find(:all, :conditions => ["deviation_deliverable_id = ? and deviation_activity_id = ?", deliverable.id, activity.id])
			questions.each do |question|
				new_deviation_spider_values = DeviationSpiderValue.new
				new_deviation_spider_values.deviation_question_id = question.id
				new_deviation_spider_values.deviation_spider_deliverable_id = new_spider_deliverable.id
				new_deviation_spider_values.answer = nil
				new_deviation_spider_values.answer_reference = question.answer_reference
				new_deviation_spider_values.save
			end
		end
	end
end
