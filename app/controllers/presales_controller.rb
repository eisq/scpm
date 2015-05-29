class PresalesController < ApplicationController
	layout "tools"
	
	# Lists
	def dashboard
		# Presale Types
		@presale_types = [["All",0]]
		@presale_types = @presale_types + PresaleType.find(:all).map {|pt| [pt.title,pt.id]}

		# Query
		@presale_presale_type_id = params[:presale_presale_type_id]
		if defined?(@presale_presale_type_id) and @presale_presale_type_id != nil and @presale_presale_type_id.to_i != 0
			cond = "presale_type_id = #{@presale_presale_type_id}"
			cond = cond + " and status != 'Buyside Accepted' and status != 'Cancelled'"
			cond_s = "presale_type_id = #{@presale_presale_type_id}"
			cond_s = cond_s + " and (status = 'Buyside Accepted' or status = 'Cancelled')"
		else
			cond = "status IS NULL or (status != 'Buyside Accepted' and status != 'Cancelled')"
			cond_s = "status = 'Buyside Accepted' or status = 'Cancelled'"
		end
		@opportunities = PresalePresaleType.find(:all, :conditions=>"#{cond}", :order=>'presale_type_id')
		@opportunities_second_table = PresalePresaleType.find(:all, :conditions=>"#{cond_s}", :order=>'presale_type_id')
	end

	def projects
		if params[:show_ignored] == "false" || params[:show_ignored] == nil
			@show_ignored = false
		else
			@show_ignored = true
		end

		if params[:show_post_m_five] == "true"
			@show_post_m_five = true
		else
			@show_post_m_five = false
		end

		# Presale Types
		@presale_types_tmp = PresaleType.find(:all).map {|pt| [pt.title,pt.id]}
		@presales_types_by_id = Hash.new
		@presale_types_tmp.each do |pt|
			@presales_types_by_id[pt[1].to_s] = pt[0]
		end
		@presale_types = [["All",0]]
		@presale_types = @presale_types + @presale_types_tmp

		# Query 
		@presale_presale_type_id = params[:presale_presale_type]
		cond = ""
		if @show_ignored == true
			@projects = Project.find(:all,
			                         :joins=>["JOIN presale_ignore_projects ON presale_ignore_projects.project_id = projects.id"],
			                         :conditions=>["presale_ignore_projects.presale_type_id = ?", @presale_presale_type_id], 
			                         :group=>'projects.id')
		else
			if defined?(@presale_presale_type_id) and @presale_presale_type_id != nil and @presale_presale_type_id.to_i != 0
				cond = "((presales.id IS NULL or presale_presale_types.presale_type_id <> #{@presale_presale_type_id}) and (presale_ignore_projects.id is NULL or presale_ignore_projects.presale_type_id <> #{@presale_presale_type_id}))"
			else
				cond = "presales.id IS NULL"
			end
			@projects = Project.find(:all, 
			                         :joins=>["JOIN milestones ON projects.id = milestones.project_id",
			                         	"LEFT JOIN presales ON projects.id = presales.project_id",
			                         	"LEFT JOIN presale_presale_types ON presales.id = presale_presale_types.presale_id",
			                         	"LEFT JOIN presale_ignore_projects ON projects.id = presale_ignore_projects.project_id"],
			                         :conditions=>["is_running = true and projects.project_id is not null and #{cond}"], 
			                         :group=>'projects.id')
		end

		if @show_post_m_five
			@projects.each do |project|
				if !project.post_m_five
					@projects.delete(project)
				end
			end
		elsif !@show_post_m_five
			@projects.each do |project|
				if project.post_m_five
					@projects.delete(project)
				end
			end
		end

	end
	

	# Presale actions
	def show_presale
		# Project
		@project_id = params[:id]
		@project = Project.find(:first, :conditions => ["id = ?", @project_id])

		# Presale
		presale_type_already_filtered = params[:presale_type_id]
		if presale_type_already_filtered
			@presale_type_filtered = PresaleType.find(:first, :conditions=>['id = ?', presale_type_already_filtered])
		end
		@presale = Presale.find(:first, :conditions => ["project_id = ?", @project_id])
		if @project && !@presale
			@presale = Presale.init_with_project(@project_id)
		end

	end
	
	def show_presale_blank
		# Project
		@project_id = params[:id]
		@project = Project.find(:first, :conditions => ["id = ?", @project_id])

		# Presale
		presale_type_already_filtered = params[:presale_type_id]
		if presale_type_already_filtered
			@presale_type_filtered = PresaleType.find(:first, :conditions=>['id = ?', presale_type_already_filtered])
		end
		@presale = Presale.find(:first, :conditions => ["project_id = ?", @project_id])
		if @project && !@presale
			@presale = Presale.init_with_project(@project_id)
		end

	end

	def ignore_presale
		# Project
		project_id = params[:id]
		project = Project.find(:first, :conditions => ["id = ?", project_id])
		
		# Presale presale type
		presale_type_id = params[:presale_type_id]
		presale_type = PresaleType.find(:first, :conditions => ["id = ?", presale_type_id])

		if project && presale_type
			ignore = PresaleIgnoreProject.new
			ignore.project = project
			ignore.presale_type = presale_type
			ignore.save
		end
		redirect_to :action=>:projects, :presale_presale_type=>presale_type_id
	end

	def ignore_presale_remove
		project_id = params[:id]
		presale_type_id = params[:presale_type_id]
		presale_ignore_project = PresaleIgnoreProject.find(:first, :conditions => ["project_id = ? and presale_type_id = ?", project_id, presale_type_id])
		if presale_ignore_project != nil
			presale_ignore_project.destroy
		end
		redirect_to :action=>:projects, :presale_presale_type=>presale_type_id, :show_ignored=>true
	end

	def show_presale_by_type
		# Type
		if !params[:blank]
			presale_presale_type_id = params[:presale_presale_type]
			@presale_presale_type = PresalePresaleType.find(:first, :conditions => ["id = ?", presale_presale_type_id])
			@presale = Presale.find(:first, :conditions => ["id = ?", @presale_presale_type.presale_id])
			@lastComment = @presale_presale_type.getLastComment
		else
			presale = Presale.new
			presale.project_id = 10000
			presale.save
			@presale = Presale.find(:last, :conditions=>['project_id = ?', 10000])

			presalePresaleType = PresalePresaleType.new
			presalePresaleType.presale_id = @presale.id
			presalePresaleType.presale_type_id = params[:presale_type_id]
			presalePresaleType.opportunity_number = 0
			presalePresaleType.save
			@presale_presale_type = PresalePresaleType.find(:last, :conditions=>["presale_id = ?", @presale.id])

			@lastComment = ""
		end

		@status = ["Identified", "Project team contacted", "Presentation scheduled", "Team to recontact", "Waiting feedback from team", "Buyside creation in progress", "Buyside launched", "Buyside on hold", "Buyside Accepted", "Cancelled"]
		@complexity = ["Easy", "Medium", "Complex"]

	end


	# Presale form actions
	def show_presale_type_select
		@presale = Presale.find(:first, :conditions => ["id = ?", params[:id]])
		@presale_types = PresaleType.find(:all)
	end

	def delete_presale_presale_type
		presale_destroyed = false
		presalePresaleType = PresalePresaleType.find(:first, :conditions => ["id = ?", params[:id]])
		#searching for several opportunities on the same presale, if yes, we do nothing, if no we delete de presale
		several_presale = PresalePresaleType.find(:all, :conditions=>["presale_id = ?", presalePresaleType.presale_id])

		project_id = presalePresaleType.presale.project.id
	    presalePresaleType.destroy

		if several_presale.count < 2
			presale = Presale.find(:first, :conditions=>["id = ?", presalePresaleType.presale_id])
			presale.destroy
			presale_destroyed = true
		end
		
	    if !presale_destroyed and project_id != 10000
	    	redirect_to :action=>:show_presale, :id=>project_id
	    elsif !presale_destroyed
	    	redirect_to :action=>:show_presale_blank, :id=>project_id
	    elsif presale_destroyed
	    	redirect_to :action=>:dashboard
	    end
	end

	def update_presale_parameter
		presale_parameter_id = params[:presale_parameter_id]
		presale_parameter = PresaleParameter.find(:first, :conditions => ["id = ?", presale_parameter_id])
		if presale_parameter.status == true
			presale_parameter.status = false
		else
			presale_parameter.status = true
		end
		presale_parameter.save
		redirect_to :action=>:show_presale, :id=>presale_parameter.presale.project.id
	end

	# Form callback
	def update_presale_presale_type
		presalePresaleType = PresalePresaleType.find(:first, :conditions => ["id = ?", params[:presale_presale_type][:id]])
	    presalePresaleType.update_attributes(params[:presale_presale_type])
	    presalePresaleType.save
	    redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presalePresaleType.id
	end

	def create_presale_presale_type
		presale_id = params[:presale_id]
		presale = Presale.find(:first, :conditions => ["id = ?", presale_id])

		presale_type_id = params[:presale_type_id]
		presale_type = PresaleType.find(:first, :conditions => ["id = ?", presale_type_id])

		if presale && presale_type
			presale_presale_type = PresalePresaleType.new
			presale_presale_type.presale = presale
			presale_presale_type.presale_type = presale_type
			presale_presale_type.save
			redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presale_presale_type.id
		else
			redirect_to :action=>:index
		end
	end

	def update_presale_comment
		presale_comment = PresaleComment.find(params[:id])
    	presale_comment.comment = params[:presale_comment][:comment]
    	presale_comment.save
    	redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presale_comment.presale_presale_type.id
	end

	def create_presale_comment
		presale_comment       = PresaleComment.create(params[:presale_comment])
		presale_comment.presale_presale_type = PresalePresaleType.find(:first, :conditions => ["id = ?", params[:presale_comment][:presale_presale_type_id]])
		presale_comment.person_id = current_user.id
		presale_comment.save
    	redirect_to :action=>:show_presale_by_type, :presale_presale_type=>presale_comment.presale_presale_type.id
	end

	# Presale comments
	def presale_comment_edit
		presale_comment_id = params[:id]
		@presale_comment = PresaleComment.find(:first, :conditions => ["id = ?", presale_comment_id])
	end

	def presale_comment_add
	    presale_presale_type_id = params['id']
	    presale_presale_type = PresalePresaleType.find(:first, :conditions => ["id = ?", presale_presale_type_id])
	    if presale_presale_type
			@presale_comment = PresaleComment.new
			@presale_comment.presale_presale_type = presale_presale_type
	    end 
	end

	def presale_comment_delete
		presale_comment_id = params['presale_comment_id']
		presale_comment = PresaleComment.find(:first, :conditions =>['id = ?', presale_comment_id])
		if presale_comment
			presale_comment.delete
		end
	    render(:nothing=>true)
	end

end
