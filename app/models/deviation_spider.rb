require 'json'
require 'google_chart'

class DeviationSpider < ActiveRecord::Base
  	has_many    :deviation_spider_consolidations
  	has_many    :deviation_spider_deliverables
  	has_many	:deviation_spider_activity_values
  	has_many	:deviation_spider_deliverable_values
	belongs_to 	:milestone


	Spider_parameters = Struct.new(:deliverables, :activities, :psu_imported)
	Chart 			  = Struct.new(:meta_activity_name, :titles, :points, :points_ref)

	# ***
	# SET
	# ***
	def init_spider_data
		spider_parameters = self.get_parameters
		questions = self.get_questions

		if spider_parameters and spider_parameters.deliverables.count > 0
			spider_parameters.deliverables.each do |deliverable|
				add_deliverable(questions, deliverable, spider_parameters.activities, spider_parameters.psu_imported)
			end
		end
		deliverables_added_by_hand = self.get_deliverables_added_by_hand_in_previous_milestones
		if deliverables_added_by_hand and deliverables_added_by_hand.count > 0
			deliverables_added_by_hand.each do |deliverable|
				add_deliverable(questions, deliverable, spider_parameters.activities, spider_parameters.psu_imported, true, false)
			end
		end
	end

	def get_questions
		questions = DeviationQuestion.find(:all, 
					    		:joins => ["JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
					    			"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
					                "JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"],
					            :conditions => ["deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ?", self.milestone.project.lifecycle_object.id, self.milestone.name],
					            :group=>"deviation_questions.id")
		return questions
	end

	def add_deliverable(questions, deliverable, activities, psu_imported, is_added_by_hand=false, init_answers=false)
		#check if we didn't already recorded this deliverable for this spider
		new_spider_deliverable = DeviationSpiderDeliverable.find(:first, :conditions=>["deviation_spider_id = ? and deviation_deliverable_id = ?", self.id, deliverable.id])
		if !new_spider_deliverable
			new_spider_deliverable = DeviationSpiderDeliverable.new
			new_spider_deliverable.deviation_spider_id = self.id
			new_spider_deliverable.deviation_deliverable_id = deliverable.id
			if deliverable_not_done?(deliverable.id)
				new_spider_deliverable.not_done = true
			end
		end
		new_spider_deliverable.is_added_by_hand = is_added_by_hand
		new_spider_deliverable.save

		project_id = self.milestone.project_id
		last_reference = DeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number asc")

		if activities and activities.count > 0
			activities.each do |activity|
				to_add = false
				setting = DeviationSpiderSetting.find(:first, :conditions=>["deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name])
				if setting
					if (new_spider_deliverable.is_added_by_hand or setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used"))
						to_add = true
					end
				elsif !psu_imported or new_spider_deliverable.is_added_by_hand
					to_add = true
				end

				if to_add
					if questions and questions.count > 0
						questions.each do |question|
							if question.is_active and question.deviation_activity_id == activity.id and question.deviation_deliverable_id == deliverable.id
								question_already_recorded = DeviationSpiderValue.find(:first, :conditions=>["deviation_spider_deliverable_id = ? and deviation_question_id = ?", deliverable.id, question.id])
								if !question_already_recorded
									new_deviation_spider_values = DeviationSpiderValue.new
									new_deviation_spider_values.deviation_question_id = question.id
									new_deviation_spider_values.deviation_spider_deliverable_id = new_spider_deliverable.id
									if new_spider_deliverable.not_done
										new_deviation_spider_values.answer = false
									else
										new_deviation_spider_values.answer = nil
									end
									new_deviation_spider_values.answer_reference = question.answer_reference
									new_deviation_spider_values.save
								end
							end
						end
					end
					to_add = false
				end
			end
		end
	end

	# ***
	# GET
	# ***
	def get_parameters
		activities 		= Array.new
		deliverables 	= Array.new
		psu_imported 	= false

		# Check PSU
		deviation_spider_reference = self.milestone.project.get_current_deviation_spider_reference
		if deviation_spider_reference
			deviation_spider_reference.deviation_spider_settings.each do |setting|

				activity_parameter = DeviationActivity.find(:first, :conditions => ["name = ? and is_active = ?", setting.activity_name, true])
				deliverable_parameter = DeviationDeliverable.find(:first, :conditions => ["name = ? and is_active = ?", setting.deliverable_name, true])
				if activity_parameter and deliverable_parameter
					if !activities.include? activity_parameter
						activities << activity_parameter
					end 		

					if setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used")
						if !deliverables.include? deliverable_parameter
							deliverables << deliverable_parameter
						end
					end
					psu_imported = true
				end
			end
		else
			deliverables = DeviationDeliverable.find(:all,
			                   :joins => ["JOIN deviation_questions ON deviation_questions.deviation_deliverable_id = deviation_deliverables.id",
			                   	"JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"],
			                   	:conditions => ["deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and deviation_deliverables.is_active = ?", self.milestone.project.lifecycle_object.id, self.milestone.name, true],
			                   	:group => "deviation_questions.deviation_deliverable_id")

			activities = DeviationActivity.find(:all,
			                   :joins => ["JOIN deviation_questions ON deviation_questions.deviation_activity_id = deviation_activities.id",
			                   	"JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"],
			                   	:conditions => ["deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and deviation_activities.is_active = ?", self.milestone.project.lifecycle_object.id, self.milestone.name, true],
			                   	:group => "deviation_questions.deviation_activity_id")
		end

		return_parameters 				= Spider_parameters.new
		return_parameters.activities 	= activities
		return_parameters.deliverables  = deliverables
		return_parameters.psu_imported  = psu_imported
		return return_parameters
	end


	# ***
	# GET DELIVERABLES FROM PREVIOUS SPIDER
	# ***
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
						deliverables_found << spider_deliverable.deviation_deliverable
					end
				end
			end
		end
		return deliverables_found
	end

	# Return a list of deliverables are not be completed on the previous milestone.
	# This requirement is not needed anymore.
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

	# ***
	# GET MILESTONES
	# ***
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


	# ***
	# CHARTS
	# ***

	def generate_deliverable_chart(meta_activity_id)
		
		chart_questions = DeviationSpiderValue.find(:all, 
		:joins => [
			"JOIN deviation_spider_deliverables ON deviation_spider_deliverables.id = deviation_spider_values.deviation_spider_deliverable_id",
			"JOIN deviation_deliverables ON deviation_deliverables.id = deviation_spider_deliverables.deviation_deliverable_id",
			"JOIN deviation_questions ON deviation_questions.id = deviation_spider_values.deviation_question_id",
			"JOIN deviation_activities ON deviation_activities.id = deviation_questions.deviation_activity_id"
		], 
		:conditions => ["deviation_spider_deliverables.deviation_spider_id = ? and deviation_activities.deviation_meta_activity_id = ? and deviation_deliverables.is_active = ?", self.id, meta_activity_id, true], 
		:order => "deviation_deliverables.id")

		chart = Chart.new

		if chart_questions

			meta_activity_name = DeviationMetaActivity.find(:first, :conditions => ["id = ?", meta_activity_id]).name

			chart.meta_activity_name = meta_activity_name
			chart.titles 		= Array.new
			chart.points 		= Array.new
			chart.points_ref 	= Array.new
			current_deliverable 	= nil
			current_yes_count		= 0.0
			current_question_count 	= 0.0

			chart_questions.each do |question|

				# Deliverable
				if (current_deliverable == nil) or (current_deliverable.id != question.deviation_spider_deliverable.deviation_deliverable.id)
					if current_deliverable != nil
						chart.titles 	 << current_deliverable.name
						chart.points 	 << (current_yes_count / current_question_count)
						chart.points_ref << 1.0
					end

					current_deliverable = question.deviation_spider_deliverable.deviation_deliverable
					current_yes_count		= 0
					current_question_count 	= 0
				end

				# Question
				if question.answer == true
					current_yes_count = current_yes_count + 1.0
				end
				current_question_count = current_question_count + 1.0
			end

			if current_deliverable
				chart.titles 	 << current_deliverable.name
				chart.points 	 << (current_yes_count / current_question_count)
				chart.points_ref << 1.0

				if chart.titles.count <= 2
					chart.titles << ""
					chart.points << 0.0
					chart.points_ref << 0.0
				end
			end
		end
		return chart
	end

	def generate_activity_chart(meta_activity_id)
		chart_questions = DeviationSpiderValue.find(:all, 
		:joins => ["JOIN deviation_spider_deliverables ON deviation_spider_deliverables.id = deviation_spider_values.deviation_spider_deliverable_id",
		"JOIN deviation_questions ON deviation_questions.id = deviation_spider_values.deviation_question_id",
		"JOIN deviation_activities ON deviation_activities.id = deviation_questions.deviation_activity_id"], 
		:conditions => ["deviation_spider_deliverables.deviation_spider_id = ? and deviation_activities.deviation_meta_activity_id = ? and deviation_activities.is_active = ?", self.id, meta_activity_id, true], 
		:order => "deviation_activities.id")

		chart = Chart.new

		if chart_questions

			meta_activity_name = DeviationMetaActivity.find(:first, :conditions => ["id = ?", meta_activity_id]).name

			chart.titles 		= Array.new
			chart.points 		= Array.new
			chart.points_ref 	= Array.new
			chart.meta_activity_name = meta_activity_name
			current_activity 	= nil
			current_yes_count		= 0.0
			current_question_count 	= 0.0

			chart_questions.each do |question|

				# Activities
				if (current_activity == nil) or (current_activity.id != question.deviation_question.deviation_activity_id)
					if current_activity != nil
						chart.titles 	 << current_activity.name
						chart.points 	 << (current_yes_count / current_question_count)
						chart.points_ref << 1.0
					end

					current_activity = question.deviation_question.deviation_activity
					current_yes_count		= 0.0
					current_question_count 	= 0.0
				end

				# Question
				if question.answer == true
					current_yes_count = current_yes_count + 1.0
				end
				current_question_count = current_question_count + 1.0
			end

			if current_activity
				chart.titles 	 << current_activity.name
				chart.points 	 << (current_yes_count / current_question_count)
				chart.points_ref << 1.0

				if chart.titles.count <= 2
					chart.titles << ""
					chart.points << 0.0
					chart.points_ref << 0.0
				end
			end
		end
		return chart
	end

	def generate_deliverable_charts
		meta_activities = DeviationMetaActivity.find(:all, :conditions=>["is_active = 1"])

		charts = Array.new
		meta_activities.each do |meta_activity|
			charts << generate_deliverable_chart(meta_activity)
		end
		return charts
	end
	def generate_activity_charts
		meta_activities = DeviationMetaActivity.find(:all, :conditions=>["is_active = 1"])

		charts = Array.new
		meta_activities.each do |meta_activity|
			charts << generate_activity_chart(meta_activity)
		end
		return charts
	end

	def generate_pie_chart
		standard = 0
		customization = 0
		deviation = 0
		total_number = 0

		reference = DeviationSpiderReference.find(:last, :conditions=>["project_id = ?", self.milestone.project_id], :order=>"version_number")
		if reference
			settings = DeviationSpiderSetting.find(:all, :conditions=>["deviation_spider_reference_id = ?", reference])
			if settings.count > 0
				settings.each do |setting|
					if setting.answer_1 == "Yes"
						standard = standard + 1
					elsif setting.answer_1 == "No" and setting.answer_2 == "No"
						deviation = deviation + 1
					else
						customization = customization + 1
					end
					total_number = total_number + 1
				end

				standard = standard.to_f / total_number.to_f * 100
				customization = customization.to_f / total_number.to_f * 100
				deviation = deviation.to_f / total_number.to_f * 100
			else
				standard = 100
			end
		else
			standard = 100
		end
		lifecycle_name = Lifecycle.find(:first, :conditions=>["id = ?", milestone.project.lifecycle_id]).name
		chart = GoogleChart::PieChart.new('500x220', "Result of "+ lifecycle_name +" adherence") do |pie_chart|
			pie_chart.data "Forecast deviation " + deviation.round.to_s + "%", deviation, "0101DF"
			pie_chart.data "Forecast customization " + customization.round.to_s + "%", customization, "5858FA"
			pie_chart.data "Standard " + standard.round.to_s + "%", standard, "A9A9F5"
		end

		return chart
	end

	def is_not_consolidated?
		result = false
		temp = DeviationSpiderConsolidationTemp.find(:first, :conditions=>["deviation_spider_id = ?", self.id])
		if temp
			result = true
		end
	end
end
