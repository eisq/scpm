require 'spreadsheet'
class DeviationSpidersController < ApplicationController
	layout "spider"

	Conso_deliverable 	= Struct.new(:deliverable, :consolidations)
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
	    	if (@last_spider) and (@last_spider.deviation_spider_consolidations.count == 0)
		    	generate_current_table(@last_spider,@meta_activity_id)
		    	check_meta_activities(@last_spider.id, @meta_activities)
	    	end

	    	# If spider consolidated
	    	if (@last_spider) and (@last_spider.deviation_spider_consolidations.count > 0)
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
	    	@meta_activity = DeviationMetaActivity.find(:first, :conditions=>["id = ?", meta_activity_id])
	    end
	    @meta_activities = DeviationMetaActivity.all.map { |ma| [ma.name, ma.id] }

	    if deviation_spider_id
	   		@last_spider = DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
		    milestone = Milestone.find(:first, :conditions=>["id = ?", @last_spider.milestone_id])
		    @project = Project.find(:first, :conditions=>["id = ?", milestone.project_id])
			generate_current_table(@last_spider,@meta_activity_id)
	    else
	    	redirect_to :controller=>:projects, :action=>:show, :id=>@project.id
	    end
	end

	# --------
	# EXPORT
	# --------
	def export_customization
		project_id = params[:project_id]
		project = Project.find(:first, :conditions => ["id = ?", project_id])
		if project
			begin
				@xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)

				deviation_spider_reference_last = DeviationSpiderReference.find(:last, :conditions => ["project_id = ?", project_id], :order_by "version_number")
				# DeliverablesSettings
				deviationSpiderSettings = DeviationSpiderSettings.find(:all, :conditions => ["deviation_spider_reference_id = ?", deviation_spider_reference_last])

				@exportCustomization = Struct.new(:name, :status, :explanation)
				@exportCustomization.name = project.name
				@exportCustomization.status = get_customization_deliverable_status(deviationSpiderSettings.answer_1, deviationSpiderSettings.answer_2, deviationSpiderSettings.answer_3)
				@exportCustomization.justification = deviationSpiderSettings.justification

				filename = spider.milestone.project.name+"_GPP_PSU_CustomizationDeviationMeasurement_Spiders_v1.0.xls"

				headers['Content-Type']         = "application/vnd.ms-excel"
		        headers['Content-Disposition']  = 'attachment; filename="'+filename+'"'
		        headers['Cache-Control']        = ''
		        render "export.erb", :layout=>false
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
				when "Deliverable N/A"
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

			# General data
	    	@deviation_spider 	= DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
	    	@activities 		= @deviation_spider.get_parameters.activities
	    	@deliverables 		= Array.new
	    	@deviation_spider.deviation_spider_deliverables.all(
	    	    :joins =>["JOIN deviation_deliverables ON deviation_spider_deliverables.deviation_deliverable_id = deviation_deliverables.id"], 
	    	    :order => ["deviation_deliverables.name"]).each do |spider_deliverable|
	    			@deliverables << spider_deliverable.deviation_deliverable
	    	end
	    	@score_list = [0,1,2,3]

	    	# Create consolidations if this is not already done
	    	if @deviation_spider.deviation_spider_consolidations.count == 0
		    	@activities.each do |activity|
		    		@deliverables.each do |deliverable|
		    			new_deviation_spider_consolidation = DeviationSpiderConsolidation.new
		    			new_deviation_spider_consolidation.deviation_spider_id = deviation_spider_id
		    			new_deviation_spider_consolidation.deviation_activity_id = activity.id
		    			new_deviation_spider_consolidation.deviation_deliverable_id = deliverable.id
		    			new_deviation_spider_consolidation.save
		    		end
		    	end
		    end

	    	# Parameters used to create the <table>
			@deviation_spider_consolidations_array = Array.new

			# Generate the data to show
			@deliverables.each do |deliverable|
				conso_deliverable = Conso_deliverable.new
				conso_deliverable.deliverable = deliverable
				conso_deliverable.consolidations = Array.new

				deviation_spider_consolidations = @deviation_spider.deviation_spider_consolidations.all(:conditions => ["deviation_deliverable_id = ?", deliverable.id], :order => "deviation_activity_id")
				deviation_spider_consolidations.each do |consolidation|
					conso_deliverable.consolidations << consolidation
				end

				@deviation_spider_consolidations_array << conso_deliverable
			end
	    else
	    	redirect_to :controller=>:projects, :action=>:index
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
			@deviation_spider 				= DeviationSpider.new
			@deviation_spider.milestone_id 	= milestone_id
			@deviation_spider.save
			@deviation_spider.init_spider_data
			redirect_to :action=>:create_spider_select_deliverables, :deviation_spider_id=>@deviation_spider.id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def set_spider_deliverables
		deliverable_ids = params[:deliverables]
		deviation_spider_id = params[:deviation_spider_id]

		if deviation_spider_id
	   		@deviation_spider = DeviationSpider.find(:first, :conditions => ["id = ?", deviation_spider_id])
			
			deliverable_ids.each do |deliverable_id|
				deviation_deliverable = DeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
				if deviation_deliverable
					deviation_spider_parameters = @deviation_spider.get_parameters
					@deviation_spider.add_deliverable(deviation_deliverable, deviation_spider_parameters.activities)
				end
			end
			render(:nothing=>true)
		end
	end

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
		deviation_spider 	= DeviationSpider.find(:last, :conditions=>["id = ?", deviation_spider_id], :order=>"id")

		if file_link != nil and deviation_spider != nil and file_link != ""
			deviation_spider.file_link = file_link
			deviation_spider.save
		end
		redirect_to :action=>:index, :milestone_id=>deviation_spider.milestone_id
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
			deviation_spider_parameters = deviation_spider.get_parameters
			deviation_spider.add_deliverable(deviation_deliverable, deviation_spider_parameters.activities, true)
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

	def update_consolidation_score
		deviation_spider_consolidation_id 		= params[:deviation_spider_consolidation_id]
		deviation_spider_consolidation_score 	= params[:deviation_spider_consolidation_score]
		if deviation_spider_consolidation_id and deviation_spider_consolidation_score
			deviation_spider_consolidation = DeviationSpiderConsolidation.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_id])
			deviation_spider_consolidation.score = deviation_spider_consolidation_score
			deviation_spider_consolidation.save
		end
		render(:nothing=>true)
	end

	def update_consolidation_text
		deviation_spider_consolidation_id 		= params[:deviation_spider_consolidation_id]
		deviation_spider_consolidation_text 	= params[:deviation_spider_consolidation_text]
		if deviation_spider_consolidation_id and deviation_spider_consolidation_text
			deviation_spider_consolidation = DeviationSpiderConsolidation.find(:first, :conditions => ["id = ?", deviation_spider_consolidation_id])
			deviation_spider_consolidation.justification = deviation_spider_consolidation_text
			deviation_spider_consolidation.save
		end
		render(:nothing=>true)
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

		deliverable_ids = spider.deviation_spider_deliverables.map {|d| d.deviation_deliverable_id }
		@deliverables_to_add = DeviationDeliverable.find(:all, 
		                      :joins=>["JOIN deviation_questions ON deviation_questions.deviation_deliverable_id = deviation_deliverables.id", 
		                      	"JOIN deviation_question_milestone_names ON deviation_question_milestone_names.deviation_question_id = deviation_questions.id",
		                      	"JOIN milestone_names ON milestone_names.id = deviation_question_milestone_names.milestone_name_id",
		                      	"JOIN deviation_question_lifecycles ON deviation_question_lifecycles.deviation_question_id = deviation_questions.id"], 
		                      	:conditions => ["deviation_deliverables.id NOT IN (?) and deviation_question_lifecycles.lifecycle_id = ? and milestone_names.title LIKE ? and deviation_deliverables.is_active = 1", deliverable_ids, spider.milestone.project.lifecycle_object.id, "%#{spider.milestone.name}%"]).map { |d| [d.name, d.id]}
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
				meta_activity_array << meta_activity[0]+" [Not completed]"
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
