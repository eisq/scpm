require 'json'
require 'google_chart'

class SvtDeviationSpider < ActiveRecord::Base
  	has_many    :svt_deviation_spider_consolidations
  	has_many    :svt_deviation_spider_deliverables
  	has_many	:svt_deviation_spider_activity_values
  	has_many	:svt_deviation_spider_deliverable_values
  	has_many	:svt_deviation_spider_maturities
	belongs_to 	:milestone
	belongs_to  :project


	Spider_parameters 		= Struct.new(:deliverables, :activities, :psu_imported)
	Chart 			  		= Struct.new(:meta_activity_name, :titles, :points, :points_ref)
	Setting_to_chart 		= Struct.new(:setting, :weight)

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
		questions = SvtDeviationQuestion.find(:all, 
					    		:joins => ["JOIN svt_deviation_question_milestone_names ON svt_deviation_question_milestone_names.svt_deviation_question_id = svt_deviation_questions.id",
					    			"JOIN milestone_names ON milestone_names.id = svt_deviation_question_milestone_names.milestone_name_id",
					                "JOIN svt_deviation_question_lifecycles ON svt_deviation_question_lifecycles.svt_deviation_question_id = svt_deviation_questions.id"],
					            :conditions => ["svt_deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ?", self.milestone.project.lifecycle_object.id, self.milestone.name],
					            :group=>"svt_deviation_questions.id")
		return questions
	end

	def add_deliverable(questions, deliverable, activities, psu_imported, is_added_by_hand=false, init_answers=false)
		#check if we didn't already recorded this deliverable for this spider
		new_spider_deliverable = SvtDeviationSpiderDeliverable.find(:first, :conditions=>["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ?", self.id, deliverable.id])

		if !new_spider_deliverable
			new_spider_deliverable = SvtDeviationSpiderDeliverable.new
			new_spider_deliverable.svt_deviation_spider_id = self.id
			new_spider_deliverable.svt_deviation_deliverable_id = deliverable.id
			if deliverable_not_done?(deliverable.id)
				new_spider_deliverable.not_done = true
			end
		end
		new_spider_deliverable.is_added_by_hand = is_added_by_hand
		new_spider_deliverable.save

		project_id = self.milestone.project_id
		last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number asc")

		if activities and activities.count > 0
			activities.each do |activity|
				to_add = false
				setting = SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name])
				if setting and setting.count == 1
					if (new_spider_deliverable.is_added_by_hand or setting[0].answer_1 == "Yes" or setting[0].answer_3 == "Another template is used")
						to_add = true
					end
				elsif setting and setting.count > 1
					setting.each do |sett|
						if (new_spider_deliverable.is_added_by_hand or sett.answer_1 == "Yes" or sett.answer_3 == "Another template is used")
							to_add = true
						end
					end
				elsif !psu_imported or new_spider_deliverable.is_added_by_hand
					to_add = true
				end

				if to_add
					if questions and questions.count > 0
						questions.each do |question|
							if question.is_active and question.svt_deviation_activity_id == activity.id and question.svt_deviation_deliverable_id == deliverable.id
								question_already_recorded = SvtDeviationSpiderValue.find(:first, :conditions=>["svt_deviation_spider_deliverable_id = ? and svt_deviation_question_id = ?", deliverable.id, question.id])
								if !question_already_recorded
									new_deviation_spider_values = SvtDeviationSpiderValue.new
									new_deviation_spider_values.svt_deviation_question_id = question.id
									new_deviation_spider_values.svt_deviation_spider_deliverable_id = new_spider_deliverable.id
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
		deviation_spider_reference = self.project.get_current_svt_deviation_spider_reference
		if deviation_spider_reference
			deviation_spider_reference.svt_deviation_spider_settings.each do |setting|
				activity_parameter = SvtDeviationActivity.find(:all,
			                   :joins => ["JOIN svt_deviation_questions ON svt_deviation_questions.svt_deviation_activity_id = svt_deviation_activities.id",
			                   	"JOIN svt_deviation_question_milestone_names ON svt_deviation_question_milestone_names.svt_deviation_question_id = svt_deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = svt_deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN svt_deviation_question_lifecycles ON svt_deviation_question_lifecycles.svt_deviation_question_id = svt_deviation_questions.id"],
			                   	:conditions => ["svt_deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and svt_deviation_activities.is_active = ? and svt_deviation_activities.name = ?", self.project.lifecycle_object.id, self.milestone.name, true, setting.activity_name])
				deliverable_parameter = SvtDeviationDeliverable.find(:first,
			                   :joins => ["JOIN svt_deviation_questions ON svt_deviation_questions.svt_deviation_deliverable_id = svt_deviation_deliverables.id",
			                   	"JOIN svt_deviation_question_milestone_names ON svt_deviation_question_milestone_names.svt_deviation_question_id = svt_deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = svt_deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN svt_deviation_question_lifecycles ON svt_deviation_question_lifecycles.svt_deviation_question_id = svt_deviation_questions.id"],
			                   	:conditions => ["svt_deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and svt_deviation_deliverables.is_active = ? and svt_deviation_deliverables.name = ?", self.project.lifecycle_object.id, self.milestone.name, true, setting.deliverable_name])
				if activity_parameter and deliverable_parameter
					if !activities.include? activity_parameter
						activities << activity_parameter
					end

					if setting.answer_1 == "Yes" or setting.answer_3 == "Another template is used"
						if !deliverables.include? deliverable_parameter
							deliverables << deliverable_parameter
						end
					end
					psu_imported = true
				end
			end
		else
			deliverables = SvtDeviationDeliverable.find(:all,
			                   :joins => ["JOIN svt_deviation_questions ON svt_deviation_questions.svt_deviation_deliverable_id = svt_deviation_deliverables.id",
			                   	"JOIN svt_deviation_question_milestone_names ON svt_deviation_question_milestone_names.svt_deviation_question_id = svt_deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = svt_deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN svt_deviation_question_lifecycles ON svt_deviation_question_lifecycles.svt_deviation_question_id = svt_deviation_questions.id"],
			                   	:conditions => ["svt_deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and svt_deviation_deliverables.is_active = ?", self.project.lifecycle_object.id, self.milestone.name, true],
			                   	:group => "svt_deviation_questions.svt_deviation_deliverable_id")

			activities = SvtDeviationActivity.find(:all,
			                   :joins => ["JOIN svt_deviation_questions ON svt_deviation_questions.svt_deviation_activity_id = svt_deviation_activities.id",
			                   	"JOIN svt_deviation_question_milestone_names ON svt_deviation_question_milestone_names.svt_deviation_question_id = svt_deviation_questions.id",
			                   	"JOIN milestone_names ON milestone_names.id = svt_deviation_question_milestone_names.milestone_name_id",
			                   	"JOIN svt_deviation_question_lifecycles ON svt_deviation_question_lifecycles.svt_deviation_question_id = svt_deviation_questions.id"],
			                   	:conditions => ["svt_deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and svt_deviation_activities.is_active = ?", self.project.lifecycle_object.id, self.milestone.name, true],
			                   	:group => "svt_deviation_questions.svt_deviation_activity_id")
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
		self.svt_deviation_spider_deliverables.each do |spider_deliverable|
			deviation_deliverables << spider_deliverable.svt_deviation_deliverable
		end

		# Get milestone index
		project_milestones = get_project_milestones_with_spider()
		self_index = get_spider_milestone_index()

		# Search for each last spider consolidated for each previous milestone if we have deviation_deliverable added by hand and with questions availables for the milestone of our current spider
		for i in 0..self_index
			project_milestone = project_milestones[i]
			last_spider = SvtDeviationSpider.find(:last, :joins=>["JOIN svt_deviation_spider_consolidations ON svt_deviation_spiders.id  = svt_deviation_spider_consolidations.svt_deviation_spider_id"], :conditions =>["milestone_id = ?", project_milestone.id] )

			if last_spider != nil
				last_spider.svt_deviation_spider_deliverables.each do |spider_deliverable|
					if spider_deliverable.is_added_by_hand and !deviation_deliverables.include? spider_deliverable.svt_deviation_deliverable
						deliverables_found << spider_deliverable.svt_deviation_deliverable
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
		self.svt_deviation_spider_deliverables.each do |spider_deliverable|
			deviation_deliverables << spider_deliverable.svt_deviation_deliverable
		end

		# Check last milestone
		project_milestones = get_project_milestones_with_spider()
		self_index = get_spider_milestone_index()

		# If the self milestone was found and it's not the first
		if self_index > 0
			previous_milestone = project_milestones[self_index-1]
			last_spider = SvtDeviationSpider.find(:last, :joins=>["JOIN svt_deviation_spider_consolidations ON svt_deviation_spiders.id  = svt_deviation_spider_consolidations.svt_deviation_spider_id"], :conditions =>["milestone_id = ?", previous_milestone.id] )

			# Check for each deliverable if one question is to false, if this is the case, we add the deliverable.
			if last_spider != nil

				last_spider.svt_deviation_spider_deliverables.each do |spider_deliverable|
					deliverable_not_completed = false

					# If one not is to null or answer is different from the ref
					spider_deliverable.svt_deviation_spider_values.each do |spider_value|
						if spider_value.answer == nil or spider_value.answer != spider_value.answer_reference
							deliverable_not_completed = true
						end
					end
					
					# Add the delivrable as not completed if not completed AND not already present in the current spider
					if deliverable_not_completed and !deviation_deliverables.include? spider_deliverable.svt_deviation_deliverable
						deliverables_availables << spider_deliverable.svt_deviation_deliverable
					end

				end
			end
		end
		return deliverables_availables
	end

	def deliverable_not_done?(deliverable_id)
		deviation_deliverables = Array.new
		self.svt_deviation_spider_deliverables.each do |spider_deliverable|
			deviation_deliverables << spider_deliverable.svt_deviation_deliverable
		end

		project_milestones = get_project_milestones_with_spider()
		self_index = get_spider_milestone_index()
		deliverable_not_done = false

		if self_index > 0
			for i in 0..(self_index-1)
				milestone_to_analyze 	= project_milestones[i]
				spider_to_analyze 		= SvtDeviationSpider.find(:last, :joins=>["JOIN svt_deviation_spider_consolidations ON svt_deviation_spiders.id  = svt_deviation_spider_consolidations.svt_deviation_spider_id"], :conditions =>["milestone_id = ?", milestone_to_analyze.id] )
				if spider_to_analyze != nil
					spider_deliverable_to_analyze = SvtDeviationSpiderDeliverable.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ?", spider_to_analyze.id, deliverable_id])
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
		
		chart_questions = SvtDeviationSpiderValue.find(:all, 
		:joins => [
			"JOIN svt_deviation_spider_deliverables ON svt_deviation_spider_deliverables.id = svt_deviation_spider_values.svt_deviation_spider_deliverable_id",
			"JOIN svt_deviation_deliverables ON svt_deviation_deliverables.id = svt_deviation_spider_deliverables.svt_deviation_deliverable_id",
			"JOIN svt_deviation_questions ON svt_deviation_questions.id = svt_deviation_spider_values.svt_deviation_question_id",
			"JOIN svt_deviation_activities ON svt_deviation_activities.id = svt_deviation_questions.svt_deviation_activity_id"
		], 
		:conditions => ["svt_deviation_spider_deliverables.svt_deviation_spider_id = ? and svt_deviation_activities.svt_deviation_meta_activity_id = ? and svt_deviation_deliverables.is_active = ?", self.id, meta_activity_id, true], 
		:order => "svt_deviation_deliverables.id")

		chart = Chart.new

		if chart_questions

			meta_activity_name = SvtDeviationMetaActivity.find(:first, :conditions => ["id = ?", meta_activity_id]).name

			chart.meta_activity_name = meta_activity_name
			chart.titles 		= Array.new
			chart.points 		= Array.new
			chart.points_ref 	= Array.new
			current_deliverable 	= nil
			current_yes_count		= 0.0
			current_question_count 	= 0.0

			chart_questions.each do |question|

				# Deliverable
				if (current_deliverable == nil) or (current_deliverable.id != question.svt_deviation_spider_deliverable.svt_deviation_deliverable.id)
					if current_deliverable != nil
						chart.titles 	 << current_deliverable.name
						chart.points 	 << (current_yes_count / current_question_count)
						chart.points_ref << 1.0
					end

					current_deliverable = question.svt_deviation_spider_deliverable.svt_deviation_deliverable
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
		chart_questions = SvtDeviationSpiderValue.find(:all, 
		:joins => ["JOIN svt_deviation_spider_deliverables ON svt_deviation_spider_deliverables.id = svt_deviation_spider_values.svt_deviation_spider_deliverable_id",
		"JOIN svt_deviation_questions ON svt_deviation_questions.id = svt_deviation_spider_values.svt_deviation_question_id",
		"JOIN svt_deviation_activities ON svt_deviation_activities.id = svt_deviation_questions.svt_deviation_activity_id"], 
		:conditions => ["svt_deviation_spider_deliverables.svt_deviation_spider_id = ? and svt_deviation_activities.svt_deviation_meta_activity_id = ? and svt_deviation_activities.is_active = ?", self.id, meta_activity_id, true], 
		:order => "svt_deviation_activities.id")

		chart = Chart.new

		if chart_questions

			meta_activity_name = SvtDeviationMetaActivity.find(:first, :conditions => ["id = ?", meta_activity_id]).name

			chart.titles 		= Array.new
			chart.points 		= Array.new
			chart.points_ref 	= Array.new
			chart.meta_activity_name = meta_activity_name
			current_activity 	= nil
			current_yes_count		= 0.0
			current_question_count 	= 0.0

			chart_questions.each do |question|

				# Activities
				if (current_activity == nil) or (current_activity.id != question.svt_deviation_question.svt_deviation_activity_id)
					if current_activity != nil
						chart.titles 	 << current_activity.name
						chart.points 	 << (current_yes_count / current_question_count)
						chart.points_ref << 1.0
					end

					current_activity = question.svt_deviation_question.svt_deviation_activity
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
		meta_activities = SvtDeviationMetaActivity.find(:all, :conditions=>["is_active = 1"])

		charts = Array.new
		meta_activities.each do |meta_activity|
			charts << generate_deliverable_chart(meta_activity)
		end
		return charts
	end
	def generate_activity_charts
		meta_activities = SvtDeviationMetaActivity.find(:all, :conditions=>["is_active = 1"])

		charts = Array.new
		meta_activities.each do |meta_activity|
			charts << generate_activity_chart(meta_activity)
		end
		return charts
	end

	def generate_pie_chart
		standard = customization = deviation = total_number = 0
		setting_to_count_array = Array.new

		reference = SvtDeviationSpiderReference.find(:last, :conditions=>["project_id = ?", self.milestone.project_id], :order=>"version_number")
		if reference
			settings = SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ?", reference])
			if settings.count > 0
				settings.each do |setting|
					setting_to_count_array = update_setting_to_count_array(setting_to_count_array, setting)
				end

				setting_to_count_array.each do |setting_to_count|
					if setting_to_count.setting.answer_1 == "Yes"
						standard = standard + 1
					elsif setting_to_count.setting.answer_1 == "No" and setting_to_count.setting.answer_2 == "No"
						deviation = deviation + 1
					else
						customization = customization + 1
					end
					total_number = total_number + 1
				end

				if total_number == 0
					total_number = 1
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

	def generate_devia_pie_chart(consolidations)
		standard = get_devia_standard(consolidations)
		deviation = 100 - standard

		lifecycle_name = Lifecycle.find(:first, :conditions=>["id = ?", self.milestone.project.lifecycle_id]).name

		chart = GoogleChart::PieChart.new('500x220', "Result of PQP adherence") do |pie_chart|
			pie_chart.data "Standard " + standard.round.to_s + "%", standard, "2E2EFE"
			pie_chart.data "Deviation " + deviation.round.to_s + "%",  deviation, "DF0101"
		end

		return chart
	end

	def get_devia_standard(consolidations)
		standard_number = number_of_duplicate = number_of_deliverables = 0
		duplicate_conso = duplicate_conso_not_set = duplicate_conso_set_no = Array.new
		last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", self.milestone.project_id], :order => "version_number asc")

		consolidations.each do |conso|
			duplication_to_delete = false
			as_been_added = false
			if conso.score == 3 or conso.score == 2
				SvtDeviationSpiderSetting.find(:all, :conditions => ["svt_deviation_spider_reference_id = ? and deliverable_name = ?", last_reference, conso.deliverable.name]).each do |sett|
					if sett.answer_1 == "Yes" or sett.answer_3 == "Another template is used"
						if !duplicate_conso.include?(conso.deliverable.name)
							standard_number = standard_number + 1
							duplicate_conso.push(conso.deliverable.name)
							as_been_added = true
						else
							duplication_to_delete = true
						end
					else
						if !duplicate_conso_set_no.include?(conso.deliverable.name)
							duplicate_conso_set_no.push(conso.deliverable.name)
						else
							duplication_to_delete = true
						end
					end
				end
			else
				if !duplicate_conso_not_set.include?(conso.deliverable.name)
					duplicate_conso_not_set.push(conso.deliverable.name)
				else
					duplication_to_delete = true
				end
			end

			if duplication_to_delete and !as_been_added
				number_of_duplicate = number_of_duplicate + 1
			end
		end

		number_of_deliverables = consolidations.count - number_of_duplicate
		standard = standard_number.to_f / number_of_deliverables.to_f * 100

		return standard
	end

	def update_setting_to_count_array(setting_to_count_array, setting)
		setting_to_count = Setting_to_chart.new
		val = true
		setting_to_count.setting = setting
		setting_to_count.weight = get_weight(setting)
		deliverable_name = setting.deliverable_name
		setting_to_count_array.each do |sett|
			if sett.setting.deliverable_name == deliverable_name
				weight_from_duplicate = sett.weight
				if setting_to_count.weight > sett.weight
					setting_to_count_array.delete(sett)
				else
					val = false
				end
			end
		end

		if val
			setting_to_count_array.push(setting_to_count)
		end

		return setting_to_count_array
	end

	def get_weight(setting)
		weight = 0

		if setting.answer_1 == "Yes"
			weight = 4
		elsif setting.answer_2 == "No"
			weight = 1
		elsif setting.answer_3 == "Another template is used"
			weight = 3
		else
			weight = 2
		end

		return weight
	end

	def is_not_consolidated?
		result = false
		temp = SvtDeviationSpiderConsolidationTemp.find(:first, :conditions=>["svt_deviation_spider_id = ?", self.id])
		if temp
			result = true
		end
	end

	def get_deviation_maturity
		maturity = i = u = 0
		SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", self.id]).each do |deliverable|
			SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ?", deliverable.id]).each do |value|
				i = i+1
				if value.answer == true
					u = u+1
				end
			end
		end

		maturity = u*100/i
		
		return maturity
	end
end
