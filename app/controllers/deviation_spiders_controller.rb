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
	end

	def generate_spider_history(milestone)
	end
end
