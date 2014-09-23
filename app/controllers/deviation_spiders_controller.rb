class DeviationSpidersController < ApplicationController
	layout "spider"

	def index
	    milestone_id = params[:milestone_id]

	    @milestone 	= Milestone.find(:first, :conditions=>["id = ?", milestone_id])  
	    @project 	= @milestone.project


	    @current_spider = nil
		# Search the last spider
   		last_spider = DeviationSpider.last(:conditions => ["milestone_id= ?", milestone_id])
    
    	# If not spider currently edited
    	if ((!last_spider) || (last_spider.deviation_spider_consolidations.count != 0))
    		
    	else

    	end
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
			@deviation_spider 				= DeviationSpider.new
			@deviation_spider.milestone_id 	= milestone_id
			@deviation_spider.save
			@deviation_spider.init_spider_data
			redirect_to :action=>:index, :milestone_id=>milestone_id
		else
			redirect_to :controller=>:projects, :action=>:index
		end
	end

end
