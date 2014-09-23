class DeviationSpidersController < ApplicationController
	layout "spider"

	def index
	    milestone_id = params[:milestone_id]

	    @milestone 	= Milestone.find(:first, :conditions=>["id = ?", milestone_id])  
	    @project 	= @milestone.project

	    # call generate_current_table
	    # generate_current_table(@project,@milestone,create_spider_param)
	    # Search all spider from history (link)
	    # create_spider_history(@project,@milestone)
	end

	def update_spider
	end

	def create_spider
	    milestone_id 	= params[:milestone_id]
	    @milestone 	= Milestone.find(:first, :conditions=>["id = ?", milestone_id])  

		@deviation_project = nil
		if @milestone
			@deviation_project = DeviationProject.new
			@deviation_project.project_id 	= @milestone.project.id
			@deviation_project.milestone_id = milestone_id
			@deviation_project.init_spider_data
			@deviation_project.save
			redirect_to :action=>:index, :milestone_id=>milestone_id
		end
		redirect_to :controller=>:projects, :action=>:index
	end

end
