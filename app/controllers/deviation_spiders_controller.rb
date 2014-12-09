require 'spreadsheet'
class DeviationSpidersController < ApplicationController
	layout "spider"

	ExportCustomization = Struct.new(:activity, :name, :status, :justification)
	Consolidation = Struct.new(:conso_id, :spider_id, :deliverable, :activity, :score, :justification)
	SPIDER_CONSO_AQ = 1
	SPIDER_CONSO_COUNTER = 2
	# 
	# INTERFACES
	# 
	def index
	    milestone_id 	 = params[:milestone_id]
	    @meta_activity_id = params[:meta_activity_id]
	    if @meta_activity_id == nil
	    	@meta_activity = DeviationMetaActivity.find(:first)
	    	@meta_activity_id = @meta_activity.id
	    else
	    	@meta_activity = DeviationMetaActivity.find(:first, :conditions=>["id = ?", @meta_activity_id])
	    end
	    @meta_activities = DeviationMetaActivity.find(:all, :conditions=>["is_active = ?", true]).map { |ma| [ma.name, ma.id] }

	    if milestone_id
		    @milestone 	 = Milestone.find(:first, :conditions=>["id = ?", milestone_id])
		    @project 	 = Project.find(:first, :conditions=>["id = ?", @milestone.project_id])
	   		@last_spider = DeviationSpider.last(:conditions => ["milestone_id= ?", milestone_id])

	    	# If spider currently edited
	    	if (@last_spider)
	    		if @last_spider.deviation_spider_consolidations.count == 0
			    	generate_current_table(@last_spider, @meta_activity_id)
			    	check_meta_activities(@last_spider.id, @meta_activities)
		    	end
		    	generate_spider_history(@milestone)
	    	end
	    else
	    	redirect_to :controller=>:projects, :action=>:show, :id=>@project.id
	    end
	end

	def index_history
	    deviation_spider_id = params[:deviation_spider_id]
	    @meta_activity_id 	= params[:meta_activity_id]
    	if @meta_activity_id == nil
	    	@meta_activity = DeviationMetaActivity.find(:first)
	    	@meta_activity_id = @meta_activity.id
	    else
	    	@meta_activity = DeviationMetaActivity.find(:first, :conditions=>["id = ?", @meta_activity_id])
	    end
	    @meta_activities = DeviationMetaActivity.all.map { |ma| [ma.name, ma.id] }

	    if deviation_spider_id
	   		@last_spider = DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
		    @milestone = Milestone.find(:first, :conditions=>["id = ?", @last_spider.milestone_id])
		    @project = Project.find(:first, :conditions=>["id = ?", @milestone.project_id])
			generate_current_table(@last_spider,@meta_activity_id)
	    else
	    	redirect_to :controller=>:projects, :action=>:show, :id=>@project.id
	    end
	end

	def index_export_all
		#@projects = params[:projects]
		@projects = Project.find(:all, :conditions=>["supervisor_id = ?", 21])
	end

	# --------
	# EXPORT
	# --------
	def export_customization_excel
		project_id = params[:project_id]
		@project = Project.find(:first, :conditions => ["id = ?", project_id])
		if @project
			begin
				@xml = Builder::XmlMarkup.new(:indent => 1)

				deviation_spider_reference_last = DeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number")
				@exportCustomizations = Array.new
				# DeliverablesSettings: for each deliverable setting
				deviationSpiderSettings = DeviationSpiderSetting.find(:all, :conditions => ["deviation_spider_reference_id = ?", deviation_spider_reference_last]).each do |devia_settings|
					exportCustomization = ExportCustomization.new
					exportCustomization.activity = devia_settings.activity_name
					exportCustomization.name = devia_settings.deliverable_name
					exportCustomization.status = get_customization_deliverable_status(devia_settings.answer_1, devia_settings.answer_2, devia_settings.answer_3)
					exportCustomization.justification = devia_settings.justification
					@exportCustomizations << exportCustomization
				end

				filename = @project.name+"_GPP_PSU_CustomizationDeviationMeasurement_Spiders_v1.0.xls"

				headers['Content-Type']         = "application/vnd.ms-excel"
		        headers['Content-Disposition']  = 'attachment; filename="'+filename+'"'
		        headers['Cache-Control']        = ''
		        render "custo.erb", :layout=>false
	        rescue Exception => e
	        	render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
		end
	end

	def export_customization_all
		projects_id = params[:projects_id]
		filter = params[:filter]
		if projects_id
			begin
				@xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)

				@projects = Array.new

				projects_id.each do |id|
					project = Project.find(:first, :conditions=>["id = ?", id])
					@projects << project
				end

				filename = "CustomizationDeviationMeasurement_"+filter+"_v1.0.xls"

				headers['Content-Type']         = "application/vnd.ms-excel"
		        headers['Content-Disposition']  = 'attachment; filename="'+filename+'"'
		        headers['Cache-Control']        = ''
		        render "custo_all.erb", :layout=>false
	        rescue Exception => e
	        	render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
	        end
	    end
	end

	def get_customization_deliverable_status(answer_1, answer_2, answer_3)
		status = ""
		case answer_1
		when "Yes"
			status = "Project plans to use referential template to produce the deliverable"
		when "No"
			case answer_2
			when "No"
				status = "Project doesn't plan to produce deliverable without justification"
			when "Yes"
				case answer_3
				when "Deliverable N.A"
					status = "Deliverable not applicable to the project"
				when "Another template is used"
					status = "Project plans to use a different template from the referential one to produce the deliverable"
				else
					status = ""
				end
			else
				status = ""
			end
		else
			status = ""
		end

		return status
	end

	def consolidate_interface
	    deviation_spider_id = params[:deviation_spider_id]
	    @editable = params[:editable]
	    if @editable == nil
	    	@editable = false
	    end

	    if deviation_spider_id
	    	@score_list = [0,1,2,3]
	    	@deviation_spider 	= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	@all_meta_activities = DeviationMetaActivity.find(:all)
	    	@all_activities 	= DeviationActivity.find(:all)
	    	parameters = @deviation_spider.get_parameters
	    	@deliverables 		= Array.new
	    	@deviation_spider.deviation_spider_deliverables.all(
	    	    :joins =>["JOIN deviation_deliverables ON deviation_spider_deliverables.deviation_deliverable_id = deviation_deliverables.id"], 
	    	    :order => ["deviation_deliverables.name"]).each do |spider_deliverable|
	    	end
	    	
	    	if @editable
		    	#If we already have a temp conso, delete it before create a new one
				check_conso_temps = DeviationSpiderConsolidationTemp.find(:all, :conditions => ["deviation_spider_id = ?", @deviation_spider.id])
				if check_conso_temps.count > 0
					check_conso_temps.each do |conso_to_delete|
						conso_to_delete.delete
					end
				end
			end

	    	@consolidations = Array.new
	    	@all_activities.each do |activity|
	    		@deliverables.each do |deliverable|
	    			deviation_deliverable_added_by_hand = DeviationSpiderDeliverable.find(:first, :conditions => ["deviation_spider_id = ? and deviation_deliverable_id = ? and is_added_by_hand = ?", deviation_spider_id, deliverable.id, true])
	    			is_applicable_added_by_hand = existing_question_activity_deliverable(deliverable.id, activity.id)
	    			if (self.get_deliverable_activity_applicable(@deviation_spider.milestone.project_id, deliverable, activity, parameters.psu_imported) or (deviation_deliverable_added_by_hand and is_applicable_added_by_hand))
						#Consolidation in a temp table for manipulations before the real consolidation
	    				consolidation_temp = DeviationSpiderConsolidationTemp.new
	    				consolidation_temp.deviation_spider_id = @deviation_spider.id
	    				consolidation_temp.deviation_deliverable_id = deliverable.id
	    				consolidation_temp.deviation_activity_id = activity.id
	    				consolidation_temp.score = "" #here to initialize
	    				consolidation_temp.justification = "" #here to initialize

	    				if @editable
	    					consolidation_temp.save
	    					consolidation_saved = DeviationSpiderConsolidationTemp.find(:first, :conditions => ["deviation_spider_id = ? and deviation_deliverable_id = ? and deviation_activity_id = ?", @deviation_spider.id, deliverable.id, activity.id])
	    				else
	    					#We consult the tab consolidation instead of the temporary one
	    					consolidation_saved = DeviationSpiderConsolidation.find(:first, :conditions => ["deviation_spider_id = ? and deviation_deliverable_id = ? and deviation_activity_id = ?", @deviation_spider.id, deliverable.id, activity.id])
	    				end

	    				consolidation = Consolidation.new
	    				consolidation.conso_id = consolidation_saved.id
	    				consolidation.spider_id = consolidation_saved.deviation_spider_id
	    				consolidation.deliverable = DeviationDeliverable.find(:first, :conditions => ["id = ?", consolidation_saved.deviation_deliverable_id])
	    				consolidation.activity = DeviationActivity.find(:first, :conditions => ["id = ?", consolidation_saved.deviation_activity_id])
	    				consolidation.score = consolidation_saved.score
	    				consolidation.justification = consolidation_saved.justification
	    				
	    				@consolidations << consolidation
	    			end
	    		end
	    	end
	    	@consolidations = @consolidations & @consolidations
	    else
	    	redirect_to :controller=>:projects, :action=>:index
	    end
	end

	def get_deliverable_activity_applicable(project_id, deliverable, activity, psu_imported=true)
		applicable = false
		if psu_imported
			last_reference = DeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number asc")
			DeviationSpiderSetting.find(:all, :conditions=>["deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name]).each do |setting|
				if (setting and (setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used")))
					applicable = true
				end
			end
		else
			applicable = self.existing_question_activity_deliverable(deliverable.id, activity.id)
		end
		return applicable					
	end

	def existing_question_activity_deliverable(deliverable_id, activity_id)
		applicable = false
		existing_question = DeviationQuestion.find(:all, :conditions => ["deviation_deliverable_id = ? and deviation_activity_id = ?", deliverable_id, activity_id])
		if existing_question.count > 0
			applicable = true
		end
		return applicable
	end

	def update_score
		deviation_spider_consolidation_temp_id 		= params[:deviation_spider_consolidation_temp_id]
		deviation_spider_consolidation_temp_score 	= params[:deviation_spider_consolidation_temp_score]
		if deviation_spider_consolidation_temp_id and deviation_spider_consolidation_temp_score
			deviation_spider_consolidation_temp = DeviationSpiderConsolidationTemp.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_temp_id])
			deviation_spider_consolidation_temp.score = deviation_spider_consolidation_temp_score
			deviation_spider_consolidation_temp.save
		end
		render(:nothing=>true)
	end

	def update_justification
		deviation_spider_consolidation_temp_id 				= params[:deviation_spider_consolidation_temp_id]
		deviation_spider_consolidation_temp_justification 	= params[:deviation_spider_consolidation_temp_justification]
		if deviation_spider_consolidation_temp_id and deviation_spider_consolidation_temp_justification
			deviation_spider_consolidation_temp 			= DeviationSpiderConsolidationTemp.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_temp_id])
			deviation_spider_consolidation_temp.justification = deviation_spider_consolidation_temp_justification
			deviation_spider_consolidation_temp.save
		end
		render(:nothing=>true)
	end

	def consolidate_validation
		deviation_spider_id = params[:deviation_spider_id]
		@deviation_spider = DeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
		@project = @deviation_spider.milestone.project
	end

	def consolidate
		deviation_spider_id = params[:deviation_spider_id]
		list_choice = params[:list_choice]

		if deviation_spider_id
			# General data
			deviation_spider 	= DeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
			parameters 			= deviation_spider.get_parameters
	    	deliverables 		= Array.new
	    	deviation_spider.deviation_spider_deliverables.all(
	    	    :joins =>["JOIN deviation_deliverables ON deviation_spider_deliverables.deviation_deliverable_id = deviation_deliverables.id"], 
	    	    :order => ["deviation_deliverables.name"]).each do |spider_deliverable|
	    			deliverables << spider_deliverable.deviation_deliverable
	    	end

	    	# Create consolidations if this is not already done
	    	if deviation_spider.deviation_spider_consolidations.count == 0
		    	parameters.activities.each do |activity|
		    		deliverables.each do |deliverable|
	    				if self.get_deliverable_activity_applicable(deviation_spider.milestone.project_id, deliverable, activity, parameters.psu_imported)
	    					consolidation_temp = DeviationSpiderConsolidationTemp.find(:first, :conditions => ["deviation_spider_id = ?", deviation_spider_id])
	    					if consolidation_temp
				    			new_deviation_spider_consolidation = DeviationSpiderConsolidation.new
				    			new_deviation_spider_consolidation.deviation_spider_id = deviation_spider_id
				    			new_deviation_spider_consolidation.deviation_activity_id = activity.id
				    			new_deviation_spider_consolidation.deviation_deliverable_id = deliverable.id
				    			new_deviation_spider_consolidation.score = consolidation_temp.score
				    			new_deviation_spider_consolidation.justification = consolidation_temp.justification
				    			new_deviation_spider_consolidation.save

				    			consolidation_temp.delete
				    		end
			    		end
		    		end
		    	end
		    end

		     # Increment the spider counter of the project
		    project = deviation_spider.milestone.project
		    
		    if((project) && (list_choice.to_i == SPIDER_CONSO_COUNTER.to_i))
		     	deviation_spider.impact_count = true;
			    deviation_spider.save

			    # Insert in history_counter
			    streamRef = Stream.find_with_workstream(project.workstream)
			    streamRef.set_spider_history_counter(current_user,deviation_spider)

			    # Increment counter
			    project.spider_count = project.spider_count + 1
			    project.save
		    end
		    redirect_to :controller=>:projects, :action=>:show, :id=>project.id
	    else
	    	redirect_to :action=>:consolidate_validation, :deviation_spider_id => deviation_spider_id, :error => 1
	    end
	end

	def delete_current_spider
	    deviation_spider_id = params[:deviation_spider_id]
    	deviation_spider 	= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    
    	if deviation_spider.deviation_spider_consolidations.count == 0
    		DeviationSpiderActivityValue.find(:all, :conditions=>["deviation_spider_id = ?", deviation_spider.id]).each do |activityvalue|
    			activityvalue.delete
    		end
    		DeviationSpiderDeliverableValue.find(:all, :conditions=>["deviation_spider_id = ?", deviation_spider.id]).each do |deliverablevalue|
    			deliverablevalue.delete
    		end
    		DeviationSpiderDeliverable.find(:all, :conditions=>["deviation_spider_id = ?", deviation_spider.id]).each do |deliverable|
    			DeviationSpiderValue.find(:all, :conditions=>["deviation_spider_deliverable_id = ?", deliverable.id]).each do |value|
    				value.delete
    			end
    			deliverable.delete
    		end
    		deviation_spider.delete
	    end
	    redirect_to :controller=>:projects, :action=>:show, :id=>deviation_spider.milestone.project.id
	end

	def delete_consolidated_spider
	    deviation_spider_id = params[:deviation_spider_id]
    	deviation_spider 	= DeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
    	if deviation_spider and deviation_spider.deviation_spider_consolidations.count > 0
    		DeviationSpiderActivityValue.find(:all, :conditions=>["deviation_spider_id = ?", deviation_spider.id]).each do |activityvalue|
    			activityvalue.delete
    		end
    		DeviationSpiderConsolidation.find(:all, :conditions=>["deviation_spider_id = ?", deviation_spider.id]).each do |consolidation|
    			consolidation.delete
    		end
    		DeviationSpiderDeliverableValue.find(:all, :conditions=>["deviation_spider_id = ?", deviation_spider.id]).each do |deliverablevalue|
    			deliverablevalue.delete
    		end
    		DeviationSpiderDeliverable.find(:all, :conditions=>["deviation_spider_id = ?", deviation_spider.id]).each do |deliverable|
    			DeviationSpiderValue.find(:all, :conditions=>["deviation_spider_deliverable_id = ?", deliverable.id]).each do |value|
    				value.delete
    			end
    			deliverable.delete
    		end
    		deviation_spider.delete
	    end
	    redirect_to :controller=>:projects, :action=>:show, :id=>deviation_spider.milestone.project.id
	end

	def create_spider_select_deliverables
		deviation_spider_id = params[:deviation_spider_id]
		if deviation_spider_id
	   		@deviation_spider = DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def get_deliverable_chart
		deviation_spider_id = params[:deviation_spider_id]
	    meta_activity_id 	= params[:meta_activity_id]

	    if deviation_spider_id and meta_activity_id
	    	deviation_spider 	= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	chart_data = deviation_spider.generate_deliverable_chart(meta_activity_id)
	    end

	    render(:text=>chart_data.to_json)
	end

	def get_activity_chart
		deviation_spider_id = params[:deviation_spider_id]
	    meta_activity_id 	= params[:meta_activity_id]

	    if deviation_spider_id and meta_activity_id
	    	deviation_spider 	= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	chart_data = deviation_spider.generate_activity_chart(meta_activity_id)
	    end

	    render(:text=>chart_data.to_json)
	end

	def get_deliverable_charts
		deviation_spider_id = params[:deviation_spider_id]

		charts = Array.new
	    if deviation_spider_id
	    	deviation_spider 	= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	charts = deviation_spider.generate_deliverable_charts
	    end

	    render(:text=>charts.to_json)
	end

	def get_activity_charts
		deviation_spider_id = params[:deviation_spider_id]
		
		charts = Array.new
	    if deviation_spider_id 
	    	deviation_spider 	= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	charts = deviation_spider.generate_activity_charts
	    end

	    render(:text=>charts.to_json)
	end
	# 
	# ACTIONS WITHOUT INTERFACE
	# 
	def create_spider
	    milestone_id 	= params[:milestone_id]
	    @milestone 	= Milestone.find(:first, :conditions=>["id = ?", milestone_id])  

		@deviation_project = nil
		if @milestone
			@deviation_spider = DeviationSpider.new
			@deviation_spider.milestone_id = milestone_id
			@deviation_spider.save
			@deviation_spider.init_spider_data
			redirect_to :action =>:index, :milestone_id => milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	#def set_spider_deliverables
	#	deliverable_ids = params[:deliverables]
	#	deviation_spider_id = params[:deviation_spider_id]
	#
	#	if deviation_spider_id
	#   		@deviation_spider = DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	#		
	#		deliverable_ids.each do |deliverable_id|
	#			deviation_deliverable = DeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
	#			if deviation_deliverable
	#				deviation_spider_parameters = @deviation_spider.get_parameters
	#				@deviation_spider.add_deliverable(deviation_deliverable, deviation_spider_parameters.activities, deviation_spider_parameters.psu_imported)
	#			end
	#		end
	#		render(:nothing=>true)
	#	end
	#end

	def update_question
		deviation_spider_value_id = params[:deviation_spider_value_id]
		deviation_spider_value_answer = params[:deviation_spider_value_answer]
		deviation_spider_value = DeviationSpiderValue.find(:first, :conditions => ["id = ?", deviation_spider_value_id])

		#when user select a 'yes' in a deliverable, button "all answer for the deliverable to no" becomes grey (not selected)
		if to_boolean(deviation_spider_value_answer)
			deviation_spider_value.deviation_spider_deliverable.not_done = false
			deviation_spider_value.deviation_spider_deliverable.save
		end

		if deviation_spider_value.answer == to_boolean(deviation_spider_value_answer)
			deviation_spider_value.answer = nil
		else
			deviation_spider_value.answer = to_boolean(deviation_spider_value_answer)
		end
		deviation_spider_value.save

		# Update other questions
		updated_spider_value_id = Array.new
		deviation_spider = deviation_spider_value.deviation_spider_deliverable.deviation_spider
		
		deviation_spider.deviation_spider_deliverables.each do |deliverable|
			deliverable.deviation_spider_values.each do |value|
				if deviation_spider_value.deviation_spider_deliverable_id == value.deviation_spider_deliverable_id and deviation_spider_value.deviation_question.question_text == value.deviation_question.question_text and value.id != deviation_spider_value.id
					updated_spider_value_id << value.id.to_s
					if value.answer == to_boolean(deviation_spider_value_answer)
						value.answer = nil
					else
						value.answer = to_boolean(deviation_spider_value_answer)
					end
					value.save
				end
			end
		end

		render(:text=>updated_spider_value_id.join(','))
	end

	def update_file_link
		deviation_spider_id = file_link = nil
		deviation_spider_id = params[:deviation_id]
		file_link 			= params[:file_link]
		redirect 			= params[:redirect]
		deviation_spider 	= DeviationSpider.find(:last, :conditions=>["id = ?", deviation_spider_id], :order=>"id")

		if file_link != nil and deviation_spider != nil and file_link != ""
			deviation_spider.file_link = file_link
			deviation_spider.save
		end

		if redirect and redirect == "index_history"
			redirect_to :action=>:index_history, :deviation_spider_id=>deviation_spider.id
		else
			redirect_to :action=>:index, :milestone_id=>deviation_spider.milestone_id
		end
	end

	def delete_spider_deliverable
		deviation_spider_deliverable_id = params[:deviation_spider_deliverable_id]
		if deviation_spider_deliverable_id
			deviation_spider_deliverable = DeviationSpiderDeliverable.find(:first, :conditions => ["id = ?", deviation_spider_deliverable_id])
			milestone_id = deviation_spider_deliverable.deviation_spider.milestone_id
			deviation_spider_deliverable.destroy
			redirect_to :action=>:index, :milestone_id=>milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def add_spider_deliverable
		deviation_spider_id 			= params[:deviation_spider_id]
		deviation_deliverable_id 		= params[:deviation_deliverable_id]
		if deviation_spider_id and deviation_deliverable_id
			deviation_deliverable 		= DeviationDeliverable.find(:first, :conditions => ["id = ?", deviation_deliverable_id])
			deviation_spider 			= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
			parameters 					= deviation_spider.get_parameters
			questions 					= deviation_spider.get_questions
			deviation_spider.add_deliverable(questions, deviation_deliverable, parameters.activities, parameters.psu_imported, true, false)
			redirect_to :action=>:index, :milestone_id=>deviation_spider.milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def set_false_for_spider_deliverable
		meta_activity_id = params[:meta_activity_id]
		deviation_spider_deliverable_id = params[:deviation_spider_deliverable_id]
		if deviation_spider_deliverable_id
			deviation_spider_deliverable = DeviationSpiderDeliverable.find(:first, :conditions => ["id = ?", deviation_spider_deliverable_id])
			deviation_spider_deliverable.not_done = 1
			deviation_spider_deliverable.save
			deviation_spider_deliverable.deviation_spider_values.each do |s|
				s.answer = 0
				s.save
			end

			redirect_to :action=>:index, :milestone_id=>deviation_spider_deliverable.deviation_spider.milestone_id, :meta_activity_id=>meta_activity_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	# **
	# INTERNAL
	# **
	def generate_current_table(spider, meta_activity_id)
		@questions = DeviationSpiderValue.find(:all, 
		:joins => ["JOIN deviation_spider_deliverables ON deviation_spider_deliverables.id = deviation_spider_values.deviation_spider_deliverable_id",
		"JOIN deviation_questions ON deviation_questions.id = deviation_spider_values.deviation_question_id",
		"JOIN deviation_activities ON deviation_activities.id = deviation_questions.deviation_activity_id",
		"JOIN deviation_deliverables ON deviation_deliverables.id = deviation_spider_deliverables.deviation_deliverable_id"], 
		:conditions => ["deviation_spider_deliverables.deviation_spider_id = ? and deviation_activities.deviation_meta_activity_id = ?", spider.id, meta_activity_id], 
		:order => "deviation_activities.name , deviation_deliverables.name, deviation_questions.question_text")

		#Search in the list of all deliverables for a milestone, if there is one which is not present in the current spider.
		last_reference 			= DeviationSpiderReference.find(:last, :conditions => ["project_id = ?", spider.milestone.project_id], :order => "version_number asc")
		deliverable_ids 		= spider.deviation_spider_deliverables.map {|d| d.deviation_deliverable_id }
		deliverable_ids_cleaned = Array.new

		if last_reference
			#in deliverable_ids, we have all referenced deliverables, even if in the setting we say that we don't want it.
			deliverable_ids.each do |deliv|
				if supposed_to_be_added(spider.id, last_reference.id, deliv)
					deliverable_ids_cleaned << deliv
				end
			end
		else
			deliverable_ids_cleaned = deliverable_ids
		end

		deliverables_to_add = DeviationDeliverable.find(:all, 
		                      :joins=>["JOIN deviation_questions ON deviation_questions.deviation_deliverable_id = deviation_deliverables.id", 
		                      	"JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
		                      	"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
		                      	"JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"], 
		                      	:conditions => ["deviation_deliverables.id NOT IN (?) and deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and deviation_deliverables.is_active = 1", deliverable_ids_cleaned, spider.milestone.project.lifecycle_object.id, spider.milestone.name]).map { |d| [d.name, d.id]}
		@deliverables_to_add = deliverables_to_add & deliverables_to_add
	end

	#check if in the seetings we said that it shall be added
	def supposed_to_be_added(spider_id, last_reference_id, deliverable_id)
		to_add 				= false
		deliverable 		= DeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
		spider_deliverable 	= DeviationSpiderDeliverable.find(:first, :conditions => ["deviation_spider_id = ? and deviation_deliverable_id = ?", spider_id, deliverable_id])
		settings 			= DeviationSpiderSetting.find(:all, :conditions => ["deviation_spider_reference_id = ? and deliverable_name = ?", last_reference_id, deliverable.name])
		if settings
			settings.each do |setting|
				if (setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used"))
					to_add = true
				end
			end
		end

		if spider_deliverable.is_added_by_hand
			to_add = true
		end

		return to_add
	end

	def check_meta_activities(spider_id, meta_activities)
		new_meta_activities_array = Array.new
		meta_activities.each do |meta_activity|
			questions_nil_count = DeviationSpiderValue.count(
			    :joins => ["JOIN deviation_spider_deliverables ON deviation_spider_deliverables.id = deviation_spider_values.deviation_spider_deliverable_id",
				"JOIN deviation_questions ON deviation_questions.id = deviation_spider_values.deviation_question_id",
				"JOIN deviation_activities ON deviation_activities.id = deviation_questions.deviation_activity_id"],
				:conditions => ["deviation_spider_values.answer IS NULL and deviation_activities.deviation_meta_activity_id = ? and deviation_spider_deliverables.deviation_spider_id = ?", meta_activity[1], spider_id])

			if questions_nil_count > 0
				meta_activity_array = Array.new
				meta_activity_array << meta_activity[0]+" [Not filled in]"
				meta_activity_array << meta_activity[1]
				new_meta_activities_array << meta_activity_array
			else 
				new_meta_activities_array << meta_activity
			end
		end
		@meta_activities = new_meta_activities_array
	end

	def generate_spider_history(milestone)
		@history = Array.new
		DeviationSpider.find(:all,
		    :select => "DISTINCT(deviation_spiders.id),deviation_spiders.created_at",
    		:joins => 'JOIN deviation_spider_consolidations ON deviation_spiders.id = deviation_spider_consolidations.deviation_spider_id',
    		:conditions => ["milestone_id= ?", milestone.id]).each { |s| @history.push(s) }
	end


	def to_boolean(str)
      str == 'true'
    end
end
