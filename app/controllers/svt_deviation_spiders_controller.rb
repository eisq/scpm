require 'spreadsheet'
class SvtDeviationSpidersController < ApplicationController
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
	    empty			 = params[:empty]
	    if empty
	    	@empty = "<br/><strong>Please answer all questions before to consolidate</strong>"
	    end
	    @meta_activity_id = params[:meta_activity_id]
	    if @meta_activity_id == nil
	    	@meta_activity = SvtDeviationMetaActivity.find(:first)
	    	@meta_activity_id = @meta_activity.id
	    else
	    	@meta_activity = SvtDeviationMetaActivity.find(:first, :conditions=>["id = ?", @meta_activity_id])
	    end
	    @meta_activities = SvtDeviationMetaActivity.find(:all, :conditions=>["is_active = ?", true]).map { |ma| [ma.name, ma.id] }

	    if milestone_id
		    @milestone 	 = Milestone.find(:first, :conditions=>["id = ?", milestone_id])
		    @project 	 = Project.find(:first, :conditions=>["id = ?", @milestone.project_id])

		    @show_bilan_custo = get_show_bilan_custo(@milestone)
		    
	   		@last_spider = SvtDeviationSpider.last(:conditions => ["milestone_id= ?", milestone_id])
	   		if @last_spider
	   			@pie_chart = @last_spider.generate_pie_chart.to_url
	   		end

	    	# If spider currently edited
	    	if (@last_spider)
	    		if @last_spider.svt_deviation_spider_consolidations.count == 0
			    	generate_current_table(@last_spider, @meta_activity_id)
			    	check_meta_activities(@last_spider.id, @meta_activities)

			    	conso_temp = SvtDeviationSpiderConsolidationTemp.find(:first, :conditions=>["svt_deviation_spider_id = ?", @last_spider.id])
			    	if !conso_temp
				    	deviation_spider_temp_init = SvtDeviationSpiderConsolidationTemp.new
				    	deviation_spider_temp_init.svt_deviation_spider_id = @last_spider.id
				    	deviation_spider_temp_init.save
				    end
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
	    	@meta_activity = SvtDeviationMetaActivity.find(:first)
	    	@meta_activity_id = @meta_activity.id
	    else
	    	@meta_activity = SvtDeviationMetaActivity.find(:first, :conditions=>["id = ?", @meta_activity_id])
	    end
	    @meta_activities = SvtDeviationMetaActivity.all.map { |ma| [ma.name, ma.id] }

	    if deviation_spider_id
	   		@last_spider = SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
		    @milestone = Milestone.find(:first, :conditions=>["id = ?", @last_spider.milestone_id])
		    @project = Project.find(:first, :conditions=>["id = ?", @milestone.project_id])
			generate_current_table(@last_spider,@meta_activity_id)
			if @last_spider
	   			@pie_chart = @last_spider.generate_pie_chart.to_url
	   		end
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
		@milestone_name = params[:milestone_name]
		@project = Project.find(:first, :conditions => ["id = ?", project_id])
		if @project
			begin
				@xml = Builder::XmlMarkup.new(:indent => 1)

				deviation_spider_reference_last = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number")
				@exportCustomizations = Array.new
				# DeliverablesSettings: for each deliverable setting
				deviationSpiderSettings = SvtDeviationSpiderSetting.find(:all, :conditions => ["svt_deviation_spider_reference_id = ?", deviation_spider_reference_last]).each do |devia_settings|
					exportCustomization = ExportCustomization.new
					exportCustomization.activity = devia_settings.activity_name
					exportCustomization.name = devia_settings.deliverable_name
					exportCustomization.status = get_customization_deliverable_status(devia_settings.answer_1, devia_settings.answer_2, devia_settings.answer_3)
					exportCustomization.justification = devia_settings.justification
					@exportCustomizations << exportCustomization
				end
				lifecycle = Lifecycle.find(:first, :conditions=>["id = ?", @project.lifecycle_id])
				filename = @project.name+"_"+lifecycle.name+"_PSU_CustomizationDeviationMeasurement_Spiders_v1.0.xls"

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
				@xml = Builder::XmlMarkup.new(:indent => 1)

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

	def export_customization_pie(chart)
		chart.getImageURI()
		render(:nothing=>true)
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
	    if deviation_spider_id
	    	@deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])

	    	redirect = false
		    SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider_id]).each do |deliverable|
		    	SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ?", deliverable]).each do |value|
		    		if value.answer == nil
		    			redirect = true
		    		end
		    	end
		    end

		    if redirect
		    	redirect_to('/svt_deviation_spiders?milestone_id='+@deviation_spider.milestone_id.to_s+'&empty=1')
			end

		    @editable = params[:editable]
		    if @editable == nil
		    	@editable = false
		    end

	    	@score_list = [0,1,2,3]
	    	@all_meta_activities = SvtDeviationMetaActivity.find(:all)
	    	@all_activities 	= SvtDeviationActivity.find(:all)
	    	parameters = @deviation_spider.get_parameters
	    	@deliverables 		= Array.new
	    	@deviation_spider.svt_deviation_spider_deliverables.all(
	    	    :joins =>["JOIN svt_deviation_deliverables ON svt_deviation_spider_deliverables.svt_deviation_deliverable_id = svt_deviation_deliverables.id"], 
	    	    :order => ["svt_deviation_deliverables.name"]).each do |spider_deliverable|
	    		@deliverables << spider_deliverable.svt_deviation_deliverable
	    	end

	    	@consolidations = Array.new
	    	@all_activities.each do |activity|
	    		@deliverables.each do |deliverable|
	    			deviation_deliverable_added_by_hand = SvtDeviationSpiderDeliverable.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and is_added_by_hand = ?", deviation_spider_id, deliverable.id, true])
	    			is_applicable_added_by_hand = existing_question_activity_deliverable(deliverable.id, activity.id, @deviation_spider.milestone)
	    			if (self.get_deliverable_activity_applicable(@deviation_spider.milestone.project_id, deliverable, activity, @deviation_spider.milestone, parameters.psu_imported) or (deviation_deliverable_added_by_hand and is_applicable_added_by_hand))
						consolidation_saved = SvtDeviationSpiderConsolidationTemp.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", @deviation_spider.id, deliverable.id, activity.id])
						if !consolidation_saved and @editable
							#Consolidation in a temp table for manipulations before the real consolidation
		    				consolidation_temp = SvtDeviationSpiderConsolidationTemp.new
		    				consolidation_temp.svt_deviation_spider_id = @deviation_spider.id
		    				consolidation_temp.svt_deviation_deliverable_id = deliverable.id
		    				consolidation_temp.svt_deviation_activity_id = activity.id
		    				consolidation_temp.score = self.get_score(@deviation_spider.id, deliverable, activity)
		    				consolidation_temp.justification = self.get_justification(@deviation_spider.id, deliverable, activity, consolidation_temp.score)

		    				consolidation_temp.save
	    					consolidation_saved = consolidation_temp
						elsif !consolidation_saved and !@editable
	    					#We consult the tab consolidation instead of the temporary one
	    					consolidation_saved = SvtDeviationSpiderConsolidation.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", @deviation_spider.id, deliverable.id, activity.id])
	    				end

	    				consolidation = Consolidation.new
	    				consolidation.conso_id = consolidation_saved.id
	    				consolidation.spider_id = consolidation_saved.svt_deviation_spider_id
	    				consolidation.deliverable = SvtDeviationDeliverable.find(:first, :conditions => ["id = ?", consolidation_saved.svt_deviation_deliverable_id])
	    				consolidation.activity = SvtDeviationActivity.find(:first, :conditions => ["id = ?", consolidation_saved.svt_deviation_activity_id])
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

	def get_deliverable_activity_applicable(project_id, deliverable, activity, milestone, psu_imported=true)
		applicable = false
		if psu_imported
			last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order => "version_number asc")
			SvtDeviationSpiderSetting.find(:all, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name]).each do |setting|
				if (setting and (setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used")))
					applicable = self.existing_question_activity_deliverable(deliverable.id, activity.id, milestone)
				end
			end
		else
			applicable = self.existing_question_activity_deliverable(deliverable.id, activity.id, milestone)
		end
		return applicable					
	end

	def get_score(deviation_spider_id, deliverable, activity)
		score = 0

		spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
		last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", spider.milestone.project_id], :order => "version_number asc")
		if last_reference
			setting = SvtDeviationSpiderSetting.find(:first, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name])

			well_used = get_deliverable_is_well_used(deviation_spider_id, deliverable, activity)

			if setting and setting.answer_1 == "Yes" and well_used
				score = 3
			elsif setting and setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used" and well_used
				score = 2
			end
		end

		return score
	end

	def get_justification(deviation_spider_id, deliverable, activity, score)
		justification = nil
		
		spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])

		if score == 2
			project_id = spider.milestone.project_id
			Milestone.find(:all, :conditions=>["project_id = ?", project_id], :order=>"id desc").each do |milestone|
				spiders = SvtDeviationSpider.find(:all, :conditions=>["milestone_id = ?", milestone.id], :order=>"id desc").each do |spider|
					consolidation = SvtDeviationSpiderConsolidation.find(:first, :conditions=>["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", spider.id, deliverable.id, activity.id])
					if consolidation
						justification = consolidation.justification
						break
					end
				end
				if justification
					break
				end
			end
		end

		if !justification
			last_reference = SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", spider.milestone.project_id], :order => "version_number asc")
			if last_reference
				setting = SvtDeviationSpiderSetting.find(:first, :conditions=>["svt_deviation_spider_reference_id = ? and deliverable_name = ? and activity_name = ?", last_reference, deliverable.name, activity.name])

				well_used = get_deliverable_is_well_used(deviation_spider_id, deliverable, activity)

				if (setting and (setting.answer_1 == "Yes" or (setting.answer_1 == "No" and setting.answer_2 == "Yes" and setting.answer_3 == "Another template is used")) and well_used)
					justification = setting.justification
				end
			end
		end

		return justification
	end

	def get_deliverable_is_well_used(deviation_spider_id, deliverable, activity)
		well_used = false
		deviation_deliverable = SvtDeviationSpiderDeliverable.find(:first, :conditions=>["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ? and not_done = ?", deviation_spider_id, deliverable.id, 0])
		if deviation_deliverable
			SvtDeviationQuestion.find(:all, :conditions=>["svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ?", deliverable.id, activity.id]).each do |question|
				deviation_value = SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ? and svt_deviation_question_id = ?", deviation_deliverable.id, question.id]).each do |value|
					if value.answer
						well_used = true
					end
				end
			end
		end

		return well_used
	end

	def existing_question_activity_deliverable(deliverable_id, activity_id, milestone)
		applicable = false
		milestone_name_id = MilestoneName.find(:first, :conditions=>["title = ?", milestone.name])
		SvtDeviationQuestion.find(:all, :conditions => ["svt_deviation_deliverable_id = ? and svt_deviation_activity_id = ? and is_active = ?", deliverable_id, activity_id, true]).each do |question|
			question_milestone = SvtDeviationQuestionMilestoneName.find(:first, :conditions=>["svt_deviation_question_id = ? and milestone_name_id = ?", question.id, milestone_name_id])
			if question_milestone
				applicable = true
			end
		end
		return applicable
	end

	def update_score
		deviation_spider_consolidation_temp_id 		= params[:deviation_spider_consolidation_temp_id]
		deviation_spider_consolidation_temp_score 	= params[:deviation_spider_consolidation_temp_score]
		if deviation_spider_consolidation_temp_id and deviation_spider_consolidation_temp_score
			deviation_spider_consolidation_temp = SvtDeviationSpiderConsolidationTemp.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_temp_id])
			deviation_spider_consolidation_temp.score = deviation_spider_consolidation_temp_score
			deviation_spider_consolidation_temp.justification = ""
			deviation_spider_consolidation_temp.save
		end
		render(:nothing=>true)
	end

	def update_justification
		deviation_spider_consolidation_temp_id 				= params[:deviation_spider_consolidation_temp_id]
		deviation_spider_consolidation_temp_justification 	= params[:deviation_spider_consolidation_temp_justification]
		if deviation_spider_consolidation_temp_id and deviation_spider_consolidation_temp_justification
			deviation_spider_consolidation_temp 			= SvtDeviationSpiderConsolidationTemp.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_temp_id])
			deviation_spider_consolidation_temp.justification = deviation_spider_consolidation_temp_justification
			deviation_spider_consolidation_temp.save
		end
		render(:nothing=>true)
	end

	def consolidate_validation
		deviation_spider_id = params[:deviation_spider_id]
		@deviation_spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
		@project = @deviation_spider.milestone.project
	end

	def consolidate
		deviation_spider_id = params[:deviation_spider_id]
		list_choice = params[:list_choice]

		if deviation_spider_id
			# General data
			deviation_spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
	    	# Create consolidations if this is not already done
	    	if deviation_spider.svt_deviation_spider_consolidations.count == 0
				SvtDeviationSpiderConsolidationTemp.find(:all, :conditions => ["svt_deviation_spider_id = ?", deviation_spider_id]).each do |temp|
	    			new_deviation_spider_consolidation = SvtDeviationSpiderConsolidation.new
	    			new_deviation_spider_consolidation.svt_deviation_spider_id = temp.svt_deviation_spider_id
	    			new_deviation_spider_consolidation.svt_deviation_activity_id = temp.svt_deviation_activity_id
	    			new_deviation_spider_consolidation.svt_deviation_deliverable_id = temp.svt_deviation_deliverable_id
	    			new_deviation_spider_consolidation.score = temp.score
	    			new_deviation_spider_consolidation.justification = temp.justification
	    			new_deviation_spider_consolidation.save

	    			temp.delete
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
    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    
    	if deviation_spider.svt_deviation_spider_consolidations.count == 0
    		SvtDeviationSpiderActivityValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |activityvalue|
    			activityvalue.delete
    		end
    		SvtDeviationSpiderDeliverableValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverablevalue|
    			deliverablevalue.delete
    		end
    		SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverable|
    			SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ?", deliverable.id]).each do |value|
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
    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions=>["id = ?", deviation_spider_id])
    	if deviation_spider and deviation_spider.svt_deviation_spider_consolidations.count > 0
    		SvtDeviationSpiderActivityValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |activityvalue|
    			activityvalue.delete
    		end
    		SvtDeviationSpiderConsolidation.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |consolidation|
    			consolidation.delete
    		end
    		SvtDeviationSpiderDeliverableValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverablevalue|
    			deliverablevalue.delete
    		end
    		SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", deviation_spider.id]).each do |deliverable|
    			SvtDeviationSpiderValue.find(:all, :conditions=>["svt_deviation_spider_deliverable_id = ?", deliverable.id]).each do |value|
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
	   		@deviation_spider = SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def get_deliverable_chart
		deviation_spider_id = params[:deviation_spider_id]
	    meta_activity_id 	= params[:meta_activity_id]

	    if deviation_spider_id and meta_activity_id
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	chart_data = deviation_spider.generate_deliverable_chart(meta_activity_id)
	    end

	    render(:text=>chart_data.to_json)
	end

	def get_activity_chart
		deviation_spider_id = params[:deviation_spider_id]
	    meta_activity_id 	= params[:meta_activity_id]

	    if deviation_spider_id and meta_activity_id
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	chart_data = deviation_spider.generate_activity_chart(meta_activity_id)
	    end

	    render(:text=>chart_data.to_json)
	end

	def get_deliverable_charts
		deviation_spider_id = params[:deviation_spider_id]

		charts = Array.new
	    if deviation_spider_id
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	charts = deviation_spider.generate_deliverable_charts
	    end

	    render(:text=>charts.to_json)
	end

	def get_activity_charts
		deviation_spider_id = params[:deviation_spider_id]
		
		charts = Array.new
	    if deviation_spider_id 
	    	deviation_spider 	= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	charts = deviation_spider.generate_activity_charts
	    end

	    render(:text=>charts.to_json)
	end

	def get_pie_chart(deviation_spider)
    	chart_data = deviation_spider.generate_pie_chart
	    return chart_data
	end

	# 
	# ACTIONS WITHOUT INTERFACE
	# 
	def create_spider
	    milestone_id 	= params[:milestone_id]
	    @milestone 	= Milestone.find(:first, :conditions=>["id = ?", milestone_id])  

		@deviation_project = nil
		if @milestone
			@deviation_spider = SvtDeviationSpider.new
			@deviation_spider.milestone_id = milestone_id
			@deviation_spider.save
			@deviation_spider.init_spider_data
			redirect_to :action =>:index, :milestone_id => milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def update_question
		deviation_spider_value_id = params[:deviation_spider_value_id]
		deviation_spider_value_answer = params[:deviation_spider_value_answer]
		deviation_spider_value = SvtDeviationSpiderValue.find(:first, :conditions => ["id = ?", deviation_spider_value_id])

		#when user select a 'yes' in a deliverable, button "all answer for the deliverable to no" becomes grey (not selected)
		if to_boolean(deviation_spider_value_answer)
			deviation_spider_value.svt_deviation_spider_deliverable.not_done = false
			deviation_spider_value.svt_deviation_spider_deliverable.save
		end

		if deviation_spider_value.answer == to_boolean(deviation_spider_value_answer)
			deviation_spider_value.answer = nil
		else
			deviation_spider_value.answer = to_boolean(deviation_spider_value_answer)
		end
		deviation_spider_value.save

		# Update other questions
		updated_spider_value_id = Array.new
		deviation_spider = deviation_spider_value.svt_deviation_spider_deliverable.svt_deviation_spider
		
		deviation_spider.svt_deviation_spider_deliverables.each do |deliverable|
			deliverable.svt_deviation_spider_values.each do |value|
				if deviation_spider_value.svt_deviation_spider_deliverable_id == value.svt_deviation_spider_deliverable_id and deviation_spider_value.svt_deviation_question.question_text == value.svt_deviation_question.question_text and value.id != deviation_spider_value.id
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
		deviation_spider 	= SvtDeviationSpider.find(:last, :conditions=>["id = ?", deviation_spider_id], :order=>"id")

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
			deviation_spider_deliverable = SvtDeviationSpiderDeliverable.find(:first, :conditions => ["id = ?", deviation_spider_deliverable_id])
			milestone_id = deviation_spider_deliverable.svt_deviation_spider.milestone_id
			deviation_spider_deliverable.destroy
			redirect_to :action=>:index, :milestone_id=>milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end


	def get_show_bilan_custo(milestone)
		show = false
		if milestone.name == "M1" or milestone.name == "M3" or milestone.name == "M5" or milestone.name == "M5/M7" or milestone.name == "G0" or milestone.name == "G2" or milestone.name == "G3" or milestone.name == "G4" or milestone.name == "G5" or milestone.name == "M5 Agile"
			show = true
		end
		return show
	end

	def add_spider_deliverable
		deviation_spider_id 			= params[:deviation_spider_id]
		deviation_deliverable_id 		= params[:deviation_deliverable_id]
		if deviation_spider_id and deviation_deliverable_id
			deviation_deliverable 		= SvtDeviationDeliverable.find(:first, :conditions => ["id = ?", deviation_deliverable_id])
			deviation_spider 			= SvtDeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
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
			deviation_spider_deliverable = SvtDeviationSpiderDeliverable.find(:first, :conditions => ["id = ?", deviation_spider_deliverable_id])
			deviation_spider_deliverable.not_done = 1
			deviation_spider_deliverable.save
			deviation_spider_deliverable.svt_deviation_spider_values.each do |s|
				s.answer = 0
				s.save
			end

			redirect_to :action=>:index, :milestone_id=>deviation_spider_deliverable.svt_deviation_spider.milestone_id, :meta_activity_id=>meta_activity_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	# **
	# INTERNAL
	# **
	def generate_current_table(spider, meta_activity_id)
		@questions = SvtDeviationSpiderValue.find(:all, 
		:joins => ["JOIN svt_deviation_spider_deliverables ON svt_deviation_spider_deliverables.id = svt_deviation_spider_values.svt_deviation_spider_deliverable_id",
		"JOIN svt_deviation_questions ON svt_deviation_questions.id = svt_deviation_spider_values.svt_deviation_question_id",
		"JOIN svt_deviation_activities ON svt_deviation_activities.id = svt_deviation_questions.svt_deviation_activity_id",
		"JOIN svt_deviation_deliverables ON svt_deviation_deliverables.id = svt_deviation_spider_deliverables.svt_deviation_deliverable_id"], 
		:conditions => ["svt_deviation_spider_deliverables.svt_deviation_spider_id = ? and svt_deviation_activities.svt_deviation_meta_activity_id = ?", spider.id, meta_activity_id], 
		:order => "svt_deviation_activities.name , svt_deviation_deliverables.name, svt_deviation_questions.question_text")

		#Search in the list of all deliverables for a milestone, if there is one which is not present in the current spider.
		last_reference 			= SvtDeviationSpiderReference.find(:last, :conditions => ["project_id = ?", spider.milestone.project_id], :order => "version_number asc")
		deliverable_ids 		= spider.svt_deviation_spider_deliverables.map {|d| d.svt_deviation_deliverable_id }
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

		deliverables_to_add = SvtDeviationDeliverable.find(:all, 
		                      :joins=>["JOIN svt_deviation_questions ON svt_deviation_questions.svt_deviation_deliverable_id = svt_deviation_deliverables.id", 
		                      	"JOIN svt_deviation_question_milestone_names ON svt_deviation_question_milestone_names.svt_deviation_question_id = svt_deviation_questions.id",
		                      	"JOIN milestone_names ON milestone_names.id = svt_deviation_question_milestone_names.milestone_name_id",
		                      	"JOIN svt_deviation_question_lifecycles ON svt_deviation_question_lifecycles.svt_deviation_question_id = svt_deviation_questions.id"], 
		                      	:conditions => ["svt_deviation_deliverables.id NOT IN (?) and svt_deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title = ? and svt_deviation_deliverables.is_active = 1", deliverable_ids_cleaned, spider.milestone.project.lifecycle_object.id, spider.milestone.name]).map { |d| [d.name, d.id]}
		@deliverables_to_add = deliverables_to_add & deliverables_to_add
	end

	#check if in the seetings we said that it shall be added
	def supposed_to_be_added(spider_id, last_reference_id, deliverable_id)
		to_add 				= false
		deliverable 		= SvtDeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
		spider_deliverable 	= SvtDeviationSpiderDeliverable.find(:first, :conditions => ["svt_deviation_spider_id = ? and svt_deviation_deliverable_id = ?", spider_id, deliverable_id])
		settings 			= SvtDeviationSpiderSetting.find(:all, :conditions => ["svt_deviation_spider_reference_id = ? and deliverable_name = ?", last_reference_id, deliverable.name])
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
			questions_nil_count = SvtDeviationSpiderValue.count(
			    :joins => ["JOIN svt_deviation_spider_deliverables ON svt_deviation_spider_deliverables.id = svt_deviation_spider_values.svt_deviation_spider_deliverable_id",
				"JOIN svt_deviation_questions ON svt_deviation_questions.id = svt_deviation_spider_values.svt_deviation_question_id",
				"JOIN svt_deviation_activities ON svt_deviation_activities.id = svt_deviation_questions.svt_deviation_activity_id"],
				:conditions => ["svt_deviation_spider_values.answer IS NULL and svt_deviation_activities.svt_deviation_meta_activity_id = ? and svt_deviation_spider_deliverables.svt_deviation_spider_id = ?", meta_activity[1], spider_id])

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
		SvtDeviationSpider.find(:all,
		    :select => "DISTINCT(svt_deviation_spiders.id),svt_deviation_spiders.created_at",
    		:joins => 'JOIN svt_deviation_spider_consolidations ON svt_deviation_spiders.id = svt_deviation_spider_consolidations.svt_deviation_spider_id',
    		:conditions => ["milestone_id= ?", milestone.id]).each { |s| @history.push(s) }
	end


	def to_boolean(str)
      str == 'true'
    end
end
