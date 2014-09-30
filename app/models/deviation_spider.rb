class DeviationSpider < ActiveRecord::Base
  	has_many    :deviation_spider_consolidations
  	has_many    :deviation_spider_deliverables
  	has_many	:deviation_spider_activity_values
  	has_many	:deviation_spider_deliverable_values
	belongs_to 	:milestone


	Spider_parameters = Struct.new(:deliverables, :activities)

	def init_spider_data
		spider_parameters = self.get_parameters

		spider_parameters.deliverables.each do |deliverable|
			add_deliverable(deliverable, spider_parameters.activities)
		end

		get_deliverables_added_by_hand_in_previous_milestones.each do |deliverable|
			add_deliverable(deliverable, spider_parameters.activities)
		end
	end

	def add_deliverable(deliverable, activities, is_added_by_hand=false, init_answers=false)
		new_spider_deliverable = DeviationSpiderDeliverable.new
		new_spider_deliverable.deviation_spider_id = self.id
		new_spider_deliverable.deviation_deliverable_id = deliverable.id
		new_spider_deliverable.is_added_by_hand = is_added_by_hand
		if deliverable_not_done?(deliverable.id)
			new_spider_deliverable.not_done = true
		end		
		new_spider_deliverable.save

		activities.each do |activity|
			questions = DeviationQuestion.find(:all, 
			    		:joins => ["JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
			    			"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
			                "JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"],
			            :conditions => ["deviation_deliverable_id = ? and deviation_activity_id = ? and deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title LIKE ?", deliverable.id, activity.id, self.milestone.project.lifecycle_object.id, "%#{self.milestone.name}%"])

			questions.each do |question|
				new_deviation_spider_values = DeviationSpiderValue.new
				new_deviation_spider_values.deviation_question_id = question.id
				new_deviation_spider_values.deviation_spider_deliverable_id = new_spider_deliverable.id
				if new_spider_deliverable.not_done
					new_deviation_spider_values.answer = false
				else
					if init_answers
						# TODO TODO TODO TODO
						# TODO : Init anwsers with previous spider deliverable.
						# Not sure if we need to do it. Wait for the requirements
					else
						new_deviation_spider_values.answer = nil
					end
				end
				new_deviation_spider_values.answer_reference = question.answer_reference
				new_deviation_spider_values.save
			end
		end
	end

	def get_parameters
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
				                                                  :conditions => ["name LIKE ?","%#{setting.deliverable_name}%"])

				if !deliverables.include? deliverable_parameter
					activities << deliverable_parameter
				end 
			end
		else
			deliverables = DeviationDeliverable.find(:all,
			                   :joins => ["JOIN deviation_questions ON deviation_questions.deviation_deliverable_id = deviation_deliverables.id",
			                   	"JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"],
			                   	:conditions => ["deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title LIKE ?", self.milestone.project.lifecycle_object.id, "%#{self.milestone.name}%"],
			                   	:group => "deviation_questions.deviation_deliverable_id")

			activities = DeviationActivity.find(:all,
			                   :joins => ["JOIN deviation_questions ON deviation_questions.deviation_activity_id = deviation_activities.id",
			                   	"JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"],
			                   	:conditions => ["deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title LIKE ?", self.milestone.project.lifecycle_object.id, "%#{self.milestone.name}%"],
			                   	:group => "deviation_questions.deviation_activity_id")
		end

		return_paramaters 				= Spider_parameters.new
		return_paramaters.activities 	= activities
		return_paramaters.deliverables  = deliverables
		return return_paramaters
	end

	def get_deliverables_added_by_hand_in_previous_milestones
		deliverables_found = Array.new

		deviation_deliverables = Array.new
		self.deviation_spider_deliverables.each do |spider_deliverable|
			deviation_deliverables << spider_deliverable.deviation_deliverable
		end

		# Get milestone index
		project_milestones = get_project_milestones_with_spider()
		self_index = get_spider_milestone_index()

		# Search for each last spider consolidated for each previous milestone if we have deviation_deliverable added by hand and with questions availables for the milestone of our current spider
		for i in 0..self_index
			project_milestone = project_milestones[i]
			last_spider = DeviationSpider.find(:last, :joins=>["JOIN deviation_spider_consolidations ON deviation_spiders.id  = deviation_spider_consolidations.deviation_spider_id"], :conditions =>["milestone_id = ?", project_milestone.id] )

			if last_spider != nil
				last_spider.deviation_spider_deliverables.each do |spider_deliverable|
					if spider_deliverable.is_added_by_hand and !deviation_deliverables.include? spider_deliverable.deviation_deliverable

						questions_count = DeviationQuestion.count(:joins=>["deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id"], :conditions=>["deviation_questions.deviation_deliverable_id = ? and milestone_names.title LIKE ?", spider_deliverable.deviation_deliverable.id, "%#{self.milestone.name}%"])
						if questions_count > 0
							deliverables_found << spider_deliverable.spider_deliverable
						end
					end
				end
			end
		end

	end

	# Return a list of deliverables are not be completed on the previous milestone.
	def get_deliverables_not_completed
		deliverables_availables = Array.new

		deviation_deliverables = Array.new
		self.deviation_spider_deliverables.each do |spider_deliverable|
			deviation_deliverables << spider_deliverable.deviation_deliverable
		end

		# Check last milestone
		project_milestones = get_project_milestones_with_spider()
		self_index = get_spider_milestone_index()

		# If the self milestone was found and it's not the first
		if self_index > 0
			previous_milestone = project_milestones[self_index-1]
			last_spider = DeviationSpider.find(:last, :joins=>["JOIN deviation_spider_consolidations ON deviation_spiders.id  = deviation_spider_consolidations.deviation_spider_id"], :conditions =>["milestone_id = ?", previous_milestone.id] )

			# Check for each deliverable if one question is to false, if this is the case, we add the deliverable.
			if last_spider != nil

				last_spider.deviation_spider_deliverables.each do |spider_deliverable|
					deliverable_not_completed = false

					# If one not is to null or answer is different from the ref
					spider_deliverable.deviation_spider_values.each do |spider_value|
						if spider_value.answer == nil or spider_value.answer != spider_value.answer_reference
							deliverable_not_completed = true
						end
					end
					
					# Add the delivrable as not completed if not completed AND not already present in the current spider
					if deliverable_not_completed and !deviation_deliverables.include? spider_deliverable.deviation_deliverable
						deliverables_availables << spider_deliverable.deviation_deliverable
					end

				end
			end
		end
		return deliverables_availables
	end

	# Return a list of milestones sorted and available for spiders
	def get_project_milestones_with_spider
		return self.milestone.project.sorted_milestones.select { |m| m.is_eligible_for_spider? and m.name[0..1]!='QG' and m.is_virtual == false }
	end

	# Return the index of the milestone of the current spider from the array of sorted milestones
	def get_spider_milestone_index
		project_milestones = get_project_milestones_with_spider()
		i = 0
		self_index = -1
		project_milestones.each do |sorted_milestone|
			if sorted_milestone.id == self.milestone.id
				self_index = i
			end
			i = i + 1
		end	
		return self_index
	end

	def deliverable_not_done?(deliverable_id)
		deviation_deliverables = Array.new
		self.deviation_spider_deliverables.each do |spider_deliverable|
			deviation_deliverables << spider_deliverable.deviation_deliverable
		end

		project_milestones = get_project_milestones_with_spider()
		self_index = get_spider_milestone_index()
		deliverable_not_done = false

		if self_index > 0
			for i in 0..(self_index-1)
				milestone_to_analyze 	= project_milestones[i]
				spider_to_analyze 		= DeviationSpider.find(:last, :joins=>["JOIN deviation_spider_consolidations ON deviation_spiders.id  = deviation_spider_consolidations.deviation_spider_id"], :conditions =>["milestone_id = ?", milestone_to_analyze.id] )
				if spider_to_analyze != nil
					spider_deliverable_to_analyze = DeviationSpiderDeliverable.find(:first, :conditions => ["deviation_spider_id = ? and deviation_deliverable_id = ?", spider_to_analyze.id, deliverable_id])
					if spider_deliverable_to_analyze != nil
						if spider_deliverable_to_analyze.not_done == true
							deliverable_not_done = true
						end
					end
				end
			end
		end

		return deliverable_not_done
	end

end
