class ProjectsController < ApplicationController

  def index
    get_projects
  end
  
  def filter
    pws = params[:ws]
    if not pws
      session[:project_filter_workstream] = nil
    else
      session[:project_filter_workstream] = "(#{pws.map{|t| "'#{t}'"}.join(',')})"
    end

    pst = params[:st]
    if not pst
      session[:project_filter_status] = nil
    else
      session[:project_filter_status] = "(#{pst.map{|t| "'#{t}'"}.join(',')})"
    end

    redirect_to(:action=>'index')
  end
  
  
  def show
    id = params['id']
    @project = Project.find(id)
    @status = @project.get_status
  end

  def edit
    id = params['id']
    @project = Project.find(id)
  end

  def edit_status
    id = params['id']
    @status = Status.find(id)
    @project = @status.project
  end

  def update
    project = Project.find(params[:id])
    project.update_attributes(params[:project])
    redirect_to :action=>:show, :id=>project.id
  end
  
  def update_status
    status = Status.find(params[:id])
    status.update_attributes(params[:status])
    status.project.update_status(params[:status][:status])
    redirect_to :action=>:show, :id=>status.project_id
  end

  # check request and suggest projects
  def import
    @import = []
    Request.find(:all, :conditions=>"project_id is null", :order=>"workstream").each { |r|
      @import << {:id=>r.id, :project_name=>r.project_name, :summary=>r.summary, :workstream=>r.workstream}
      }
  end
  
  # for each request rename project if necessary
  def check
    t = ""
    Request.find(:all, :conditions=>"project_id is not null").each { |r|
      if r.workpackage_name != r.project.name
        t << "#{r.workpackage_name} (new) != #{r.project.name} (old)<br/>" 
        project = Project.find_by_name(r.workpackage_name)
        if not project
          r.project.name = r.workpackage_name
          r.project.save
        else
          old_id = r.project_id
          r.project_id = project.id
          r.save
          old_project = Project.find(old_id)
          old_project.statuses.each { |s|
            s.project_id = project.id
            s.save
            }
          project.update_status
          old_project.name = "to delete"
          old_project.update_status # saves
        end        
      end    
      }
    t << "<br/><a href='/projects'>back to projects</a>"
    render(:text=>t)  
  end
  
  def add_status_form
    @project = Project.find(params[:project_id])
    @status = Status.new
  end
  
  def add_status
    project_id = params[:status][:project_id]
    status = Status.create(params[:status])
    p = Project.find(project_id)
    p.update_status(params[:status][:status])
    redirect_to :action=>:show, :id=>project_id
  end
  
  # link a request to a project, based on request project_name
  # if the project does not exists, create it
  def link
    request_id    = params[:id]
    request = Request.find(request_id)
    project_name  = request.project_name
    workpackage_name = request.workpackage_name
    brn = request.brn

    project = Project.find_by_name(project_name)
    if not project
      project = Project.create(:name=>project_name)
      project.workstream = request.workstream
      project.save
    end

    wp = Project.find_by_name(workpackage_name, :conditions=>["project_id=?",project.id])
    if not wp
      wp = Project.create(:name=>workpackage_name)
      wp.workstream = request.workstream
      wp.brn = brn
      wp.project_id = project.id
      wp.save
    end

    request.project_id = wp.id
    request.save
    render(:text=>"saved")
  end
  
  def cut
    session[:cut] = params[:id]
    render(:nothing=>true)
  end

  def paste
    to_id   = params[:id].to_i
    from_id = session[:cut].to_i
    from = Project.find(from_id)
    from.project_id = to_id
    from.save
    render(:nothing=>true)
  end

  def destroy
    Project.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end
  
  def report
    get_projects
    render(:layout=>'report')
  end
  
private
  
  def get_projects
    cond = "project_id is null"
    cond += " and workstream in #{session[:project_filter_workstream]}" if session[:project_filter_workstream] != nil
    cond += " and last_status in #{session[:project_filter_status]}" if session[:project_filter_status] != nil
    @projects = Project.find(:all, :conditions=>cond, :order=>'workstream, name')
    @workstreams = Project.all.collect{|p| p.workstream}.uniq.sort
  end
end

