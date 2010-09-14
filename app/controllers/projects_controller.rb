class ProjectsController < ApplicationController

  def index
    get_projects
    @supervisors  = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
    @qr           = Person.find(:all, :conditions=>"is_supervisor=0", :order=>"name asc")
    @workstreams  = Project.all.collect{|p| p.workstream}.uniq.sort
  end

  def upload
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

    sup = params[:sup]
    if not sup
      session[:project_filter_supervisor] = nil
    else
      session[:project_filter_supervisor] = "(#{sup.map{|t| "'#{t}'"}.join(',')})"
    end

    qr = params[:qr]
    if not qr
      session[:project_filter_qr] = nil
    else
      session[:project_filter_qr] = qr.map {|t| t.to_i}
    end

    session[:project_filter_text] = params[:text]

    redirect_to(:action=>'index')
  end

  def show
    id = params['id']
    @project = Project.find(id)
    @status = @project.get_status
  end

  def edit
    id = params[:id]
    @project = Project.find(id)
    @supervisors = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
  end

  def edit_status
    id = params['id']
    @status = Status.find(id)
    @project = @status.project
  end

  def update
    project = Project.find(params[:id])
    project.update_attributes(params[:project])
    project.propagate_attributes
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
        project = Project.find_by_name(r.workpackage_name)
        if not project
          t << "<u>#{r.project.name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => creating<br/>"
          parent = Project.find(:first, :conditions=>"name='#{r.project.name}'")
          parent_id = parent ? parent.id : nil
          p = Project.create(:project_id=>parent_id, :name=>r.workpackage_name, :workstream=>r.workstream) # FIXME: need to set the project_id to wich it belongs
          r.move_to_project(p)
        else
          t << "<u>#{r.project.name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => moving<br/>"
          r.move_to_project(project)
        end
      end
      }
    t << "<br/><a href='/projects'>back to projects</a>"
    render(:text=>t)
  end

  def check_sdp
    i = ImportSDP.new
    i.open('C:\Users\faivremacon\My Documents\Downloads\Rapport.xls')
    list = i.list
    i.close
    all_requests = Request.find(:all).collect {|r| r.request_id.to_i}
    no_requests  = Request.find(:all, :conditions=>"sdp!='No' and status!='cancelled'").collect {|r| r.request_id.to_i}
    @in_sdp = (list - all_requests).sort
    @in_rmt = (all_requests - list).sort
    @no_in_rmt_but_in_sdp = (list - no_requests).sort
    #render(:text=>@list.size)
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
      wp.brn        = brn
      wp.project_id = project.id
      wp.save
    end

    request.project_id = wp.id
    request.save
    render(:text=>"saved")
  end

  def cut
    session[:cut] = params[:id]
    render(:nothing => true)
  end

  def paste
    to_id   = params[:id].to_i
    cut_id  = session[:cut].to_i
    cut     = Project.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    cut.update_status
    Project.find(from_id).update_status if from_id
    render(:nothing=>true)
  end

  def destroy
    Project.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def report
    get_projects
    @report = Report.new(Request.all)
    render(:layout=>'report')
  end

private

  def get_projects
    if session[:project_filter_text] != ""
      @projects = Project.all.select {|p| p.text_filter(session[:project_filter_text]) }
      return
    end
    cond = "project_id is null"
    cond += " and workstream in #{session[:project_filter_workstream]}" if session[:project_filter_workstream] != nil
    cond += " and last_status in #{session[:project_filter_status]}" if session[:project_filter_status] != nil
    cond += " and supervisor_id in #{session[:project_filter_supervisor]}" if session[:project_filter_supervisor] != nil
    #@projects = Project.find(:all, :conditions=>cond, :order=>'workstream, name')
    @projects = Project.find(:all, :conditions=>cond)
    if session[:project_filter_qr] != nil
      @projects = @projects.select {|p| p.has_responsible(session[:project_filter_qr]) }
    end
    @projects = @projects.sort_by { |p| d = p.last_status_date; [p.project_requests_progress_status_html == 'ended' ? 1 : 0, d ? d : Time.zone.now] }
  end
end
