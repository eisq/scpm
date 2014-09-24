class DeviationSpidersController < ApplicationController
	layout "spider"

	def index
	    milestone_id 	 = params[:milestone_id]
	    @meta_activity_id = params[:meta_activity_id]
	    if @meta_activity_id == nil
	    	@meta_activity_id = DeviationMetaActivity.find(:first).id
	    end
	    @meta_activities = DeviationMetaActivity.all.map { |ma| [ma.name, ma.id] }

	    if milestone_id
		    @milestone 	 = Milestone.find(:first, :conditions=>["id = ?", milestone_id])  
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
	    	redirect_to :controller=>:projects, :action=>:index
	    end
	end

	def update_spider
	end

	def create_spider
	    milestone_id 	= params[:milestone_id]
	    @milestone 	= Milestone.find(:first, :conditions=>["id = ?", milestone_id])  

		@deviation_project = nil
		if @milestone
			@deviation_spider 				= DeviationSpider.new
			@deviation_spider.milestone_id 	= milestone_id
			@deviation_spider.save
			@deviation_spider.init_spider_data
			redirect_to :action=>:index, :milestone_id=>milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def update_question
		deviation_spider_value_id = params[:deviation_spider_value_id]
		deviation_spider_value_answer = params[:deviation_spider_value_answer]
		deviation_spider_value = DeviationSpiderValue.find(:first, :conditions => ["id = ?", deviation_spider_value_id])
		deviation_spider_value.answer = deviation_spider_value_answer
		deviation_spider_value.save
		render(:nothing=>true)
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
			deviation_spider.add_deliverable(deviation_deliverable, deviation_spider_parameters.activities)
			redirect_to :action=>:index, :milestone_id=>deviation_spider.milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	def set_false_for_spider_deliverable
		deviation_spider_deliverable_id = params[:deviation_spider_deliverable_id]
		if deviation_spider_deliverable_id
			deviation_spider_deliverable = DeviationSpiderDeliverable.find(:first, :conditions => ["id = ?", deviation_spider_deliverable_id])
			deviation_spider_deliverable.deviation_spider_values.each do |s|
				s.answer = 0
				s.save
			end

			redirect_to :action=>:index, :milestone_id=>deviation_spider_deliverable.deviation_spider.milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

	# **
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
		@deliverables_to_add = DeviationDeliverable.find(:all, :conditions => ["id NOT IN (?)", deliverable_ids]).map { |d| [d.name, d.id]}
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
end
