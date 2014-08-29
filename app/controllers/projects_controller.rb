require 'builder'

include ActionView::Helpers::DateHelper # just for time_ago_in_words...

class ProjectsController < ApplicationController

  before_filter :require_login

  def index
    @time = Time.now
    get_projects
    sort_projects
    @last_update = Request.find(:first, :select=>"updated_at", :order=>"updated_at desc" )
    if @last_update
      @last_update = @last_update.updated_at
      @last_update = "#{time_ago_in_words(@last_update)} ago (#@last_update)"
    else
      @last_update = "Never updated"
    end
    @supervisors = Person.find(:all, :conditions=>"is_supervisor=1 and has_left=0", :order=>"name asc")
    @qr          = Person.find(:all,:include => [:person_roles,:roles], :conditions=>["roles.name = 'QR' and is_supervisor=0 and has_left=0 and is_transverse=0"], :order=>"people.name asc")
    suite_tags   = SuiteTag.find(:all, :conditions => ["is_active = 1"])
    @suite_tags  = suite_tags.sort_by{ |st|
      if st[:name].scan(/\d+[,.]\d+|\d+/).count > 0
        st[:name].scan(/\d+[,.]\d+|\d+/)[0].to_f
      else
        st[:name]
      end
    }

    @workstreams = Workstream.all()
    @workstreams = @workstreams.map { |ws| ws.name }

    @actions      = Action.find(:all, :conditions=>["progress in('in_progress', 'open') and person_id in (?)", session[:project_filter_qr]])
    @actions_closed       = Action.find(:all, :conditions=>["person_id in (?) and progress in('closed','abandonned')", session[:project_filter_qr]], :order=>"due_date")
    @total_wps    = Project.count
    @total_status = Status.count

    @total_wps_filtered = @wps.size

    if @wps.size > 0
      @amendments           = Amendment.find(:all, :conditions=>"done=0 and project_id in (#{@wps.collect{|p| p.id}.join(',')})", :order=>"duedate")
      @risks                = Risk.find(:all, :conditions=>"probability>0 and project_id in (#{@wps.collect{|p| p.id}.join(',')})", :order=>"updated_at")
      @risks_with_severity  = @risks.select { |risk| risk.severity > 0}
      @inconsistencies      = @wps.select{|wp| !wp.is_consistent_with_risks}
      @checklist_milestones = @wps.map{|p| p.milestones}.flatten.select{ |m|
        m.done == 1 and
        m.checklist_items.select{ |i|
          i.ctemplate.ctype!='folder' and i.status==0
          }.size > 0
        }.sort_by { |m| [m.project.full_name, m.name] }

      i_wps = 0 
      @projects_id = ""
      @wps.each do |wp_project|
        if i_wps > 0
          @projects_id += ","
        end
        @projects_id += "'"+wp_project.id.to_s+"'"
        i_wps += 1
      end
    else
      @amendments           = []
      @risks                = []
      @risks_with_severity  = []
      @inconsistencies      = []
      @checklist_milestones = []
      @projects_id          = ""
    end
    f = session[:project_filter_qr]
    if f and f.size == 1
      filtered_person = Person.find(f[0].to_i) || current_user
      @ci = CiProject.find(:all, :conditions=>["assigned_to=?", filtered_person.rmt_user], :order=>"sqli_validation_date_review desc")
    else
      @ci = []
    end
  end

  def show_project_list
    get_projects_without_wps
    sort_projects_without_wps
  end

  def sort_projects
    case
      when session[:project_sort]=='read'
        @wps = @wps.sort_by { |p| p.read_date ? p.read_date : Time.now-1.year}
      when session[:project_sort]=='update'
        @wps = @wps.sort_by { |p| d = p.last_status_date; [p.project_requests_progress_status_html == 'ended' ? 1 : 0, d ? d : Time.zone.now] }
      when session[:project_sort]=='alpha'
        @wps = @wps.sort_by { |p| p.full_name }
      when session[:project_sort]=='workstream'
        @wps = @wps.sort_by { |p| [p.workstream, p.full_name] }
    end
  end

 def sort_projects_without_wps
    return if !@projects
    case
      when session[:project_sort]=='read'
        @projects = @projects.sort_by { |p| p.read_date ? p.read_date : Time.now-1.year }
      when session[:project_sort]=='update'
        @projects = @projects.sort_by { |p| d = p.last_status_date; [p.project_requests_progress_status_html == 'ended' ? 1 : 0, d ? d : Time.zone.now] }
      when session[:project_sort]=='alpha'
        @projects = @projects.sort_by { |p| p.full_name }
      when session[:project_sort]=='workstream'
        @projects = @projects.sort_by { |p| [p.workstream, p.full_name] }
    end
  end

  def refresh_projects
    s = params[:sort]
    session[:project_sort] = s
    get_projects
    sort_projects
    render(:partial=>'home_project', :collection=>@wps, :as=>:project, :layout=>false)
  end

  def new
    @project     = Project.new(:project_id=>nil, :name=>'')
    @qr          = Person.find(:all,:include => [:person_roles,:roles], :conditions=>["roles.name = 'QR'"], :order=>"people.name asc")
    @supervisors = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
  end

  def create
    @project = Project.new(params[:project])
    lifecycle_default = Lifecycle.get_default
    if lifecycle_default
      @project.lifecycle = lifecycle_default.id
      @project.lifecycle_object = lifecycle_default
    end
    # can not set project_id to 0 as we use that to filter projets later... but why...
    #@project.project_id = 0 if !@project.project_id
    check_qr_qwr_pdc(@project)
    if not @project.save
      render :action => 'new'
      return
    end
    redirect_to("/projects")
  end

  def upload
  end

  def filter
    pws = params[:ws]
    if not pws; session[:project_filter_workstream] = nil
    else;       session[:project_filter_workstream] = "(#{pws.map{|t| "'#{t}'"}.join(',')})"
    end
    pst = params[:st]
    if not pst; session[:project_filter_status] = nil
    else;       session[:project_filter_status] = "(#{pst.map{|t| "'#{t}'"}.join(',')})"
    end
    sup = params[:sup]
    if not sup; session[:project_filter_supervisor] = nil
    else;       session[:project_filter_supervisor] = "(#{sup.map{|t| "'#{t}'"}.join(',')})"
    end
    qr = params[:qr]
    if not qr;  session[:project_filter_qr] = nil
    else;       session[:project_filter_qr] = "(#{qr.map{|t| "'#{t}'"}.join(',')})"
    end
    suiteTags = params[:suiteTags]
    if not suiteTags; session[:project_filter_suiteTags] = nil
    else;             session[:project_filter_suiteTags] = "(#{suiteTags.map{|t| "'#{t}'"}.join(',')})"
    end

    session[:project_filter_text] = params[:text]
    redirect_to(:action=>'index')
  end

  def show
    id = params['id']
    @project = Project.find(id)
    @project.check
    @status = @project.get_status
    @old_statuses = @project.statuses - [@status]
    @sibling = Project.find(:first, :conditions => ["sibling_id = ?", @project.id])
    @has_sibling = false
    if @sibling != nil
      @has_sibling = true
    end
    #@checklist_items = TransverseItems.find()
  end

  def check_all_milestones
    Project.all.each(&:check_milestones)
    render(:nothing=>true)
  end

  def edit
    id           = params[:id]
    @project     = Project.find(id)
    @qr          = Person.find(:all,:include => [:person_roles,:roles], :conditions=>["roles.name = 'QR' and is_supervisor=0 and has_left=0"], :order=>"people.name asc")    
    @supervisors = Person.find(:all, :conditions=>"is_supervisor=1", :order=>"name asc")
    @suiteTags   = SuiteTag.find(:all)
  end

  def edit_status
    id = params['id']
    @status = Status.find(id)
    @project = @status.project
    get_risk_status_string
  end

  def update
    project             = Project.find(params[:id])
    old_is_qr_qwr_param = project.is_qr_qwr
    project.update_attributes(params[:project])

    project.propagate_attributes

    # QR QWR
    if (!project.is_qr_qwr)
      project.qr_qwr_id = nil
    end
    project.save
    check_qr_qwr_pdc(project)
    #check_qr_qwr_activated(project,old_is_qr_qwr_param)
    redirect_to :action=>:show, :id=>project.id
  end

  def add_status_form
    @project = Project.find(params[:id])
    @list_choice = params[:list_choice]
    @status = Status.new
    get_risk_status_string
    last = @project.get_status
    @status.explanation             = last.explanation
    @status.feedback                = last.feedback
    @status.reason                  = last.reason
    @status.status                  = last.status
    @status.last_change             = last.last_change
    @status.actions                 = last.actions
    @status.ereporting_date         = last.ereporting_date
    @status.operational_alert       = last.operational_alert
    @status.reporting               = last.reporting
    @status.pratice_spider_gap      = last.pratice_spider_gap
    @status.deliverable_spider_gap  = last.deliverable_spider_gap
  end

  def add_status
    project_id  = params[:status][:project_id]

    # check changes
    p           = Project.find(project_id)
    last_status = p.get_status
    status      = Status.create(params[:status])
    status_type = params[:status_type]

    t = Time.now
    if last_status
      status.reason_updated_at  = last_status.reason_updated_at
      status.reporting_at       = last_status.reporting_at
      status.reason_updated_at  = t if status.reason     != last_status.reason
      status.reporting_at       = t if status.reporting  != last_status.reporting
    else
      status.reason_updated_at  = t
      status.reporting_at      = t
    end

    status.last_modifier = current_user.id
    status.save
    p.update_attribute('read_date', Time.now) if current_user.has_role?('Admin')
    p.update_status(params[:status][:status])
    #p.save
    p.calculate_diffs

    # Counter increment if type = 2 (1 = AQ, 2 = standart, 3 = standart but not QS count increment)
    if (status_type.to_i == 2)
      # Insert in history_counter
      streamRef     = Stream.find_with_workstream(p.workstream)
      streamRef.set_qs_history_counter(current_user,status)

      # Increment QS counter
      p.qs_count = p.qs_count + 1
      p.save
    end

    #Mailer::deliver_status_change(p)
    redirect_to :action=>:show, :id=>project_id
  end

  def update_status
    timestamps_off if params[:update] != '1'
    status = Status.find(params[:id])
    status.attributes = params[:status] # does not use update_attributes as it saves the record and we can not use "changed?" anymore
    status.reason_updated_at  = Time.now if status.reason_changed?
    status.reporting_at       = Time.now if status.reporting_changed?
    status.last_modifier      = current_user.id
    status.save
    p = status.project
    p.update_status(params[:status][:status]) if p.get_status.id == status.id # only if we are updating the last status
    p.update_attribute('read_date', Time.now) if current_user.has_role?('Admin')
    p.calculate_diffs
    Mailer::deliver_status_change(p)
    timestamps_on if params[:update] != '1'
    redirect_to :action=>:show, :id=>status.project_id
  end

  # check request and suggest projects
  def import
    @import = []
    Request.find(:all, :conditions=>"project_id is null and stream_id is null", :order=>"workstream").each { |r|
      @import << r
      }
    render(:layout=>'tools')
  end

  # for each request rename project if necessary
  # find projects with nothing in it
  def check
    @text = ""
    timestamps_off
    Request.find(:all, :conditions=>"project_id is not null").each do |r|
      if r.workpackage_name != r.project.name
        projects = Project.find(:all, :conditions=>"name='#{r.workpackage_name}'")
        @text << "found #{projects.size} projects with name '#{r.workpackage_name}' (#{r.project_name})"
        projects.each { |p|
          @text << ", wp belongs to #{p.project ? p.project.name : 'no parent'}"
          projects.delete(p) if not p.project or p.project.name != r.project_name
          }
        @text << " => #{projects.size} projects has the right parent<br/>"
        #next
        if projects.size == 0
          parent = Project.find(:first, :conditions=>"name='#{r.project_name}'")
          if not parent
            # create parent
            parent_id = Project.create(:project_id=>nil, :name=>r.project_name, :workstream=>r.workstream, :lifecycle_object=>Lifecycle.first).id
          else
            parent_id = parent.id
          end
          #create wp
          p = Project.create(:project_id=>parent_id, :name=>r.workpackage_name, :workstream=>r.workstream, :lifecycle_object=>Lifecycle.first)
          if r.project.requests.size == 1 # if that was the only request move all statuts and actions, etc.. to new project
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => creating and moving ALL<br/>"
            r.project.move_all(p)
          else
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => creating and moving only request (not status and actions, etc...)<br/>"
          end
          r.move_to_project(p)
        else
          if r.project.requests.size == 1 # if that was the only request move all statuts and actions, etc.. to new project
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => moving ALL<br/>"
            r.project.move_all(projects[0])
          else
            @text << "<u>#{r.project.full_name}</u>: #{r.workpackage_name} (new) != #{r.project.name} (old) => moving only request (not status and actions, etc...)<br/>"
          end
          r.move_to_project(projects[0])
        end
      end
      if (r.project and r.project.project and r.project.project.name != r.project_name)
        @text << "FYI #{r.project.project.name} != #{r.project_name} (#{r.request_id})<br/>"
      end
      if (r.milestone != 'N/A' and (r.work_package[0..2]=="WP2" or r.work_package[0..2]=="WP3" or r.work_package[0..2]=="WP4" or r.work_package[0..2]=="WP5" or r.work_package[0..2]=="WP6"))
        @text << "not N/A for <a href='http://toulouse.sqli.com/EMN/view.php?id=#{r.request_id}'>#{r.project_name}</a><br/>"
      end
    end
    Project.find(:all, :conditions=>"supervisor_id is null and project_id is not null").each { |p|
      p.supervisor_id = p.project.supervisor_id
      p.save
      }
    @projects         = Project.find(:all, :conditions=>"is_running = 0 and is_qr_qwr = 0").select{ |p| p.projects.size == 0 and p.requests.size == 0}
    @root_requests    = Project.find(:all, :conditions=>"project_id is null").select{ |p| p.requests.size > 0}
    @display_actions  = true
    @missing_associations = find_missing_project_person_associations
    timestamps_on
    render(:layout=>'tools')
  end

  # link a request to a project, based on request project_name
  # if the project does not exists, create it
  def link
    request_id        = params[:id]
    request           = Request.find(request_id)
    project_name      = request.project_name
    workpackage_name  = request.workpackage_name
    brn               = request.brn

    project = Project.find_by_name(project_name)
    if not project
      project = Project.create(:name=>project_name)
      project.workstream = request.workstream
      lifecycle_name = request.lifecycle_name_for_request_type()
      lifecycle = nil
      if lifecycle_name
        lifecycle = Lifecycle.find(:first, :conditions => ["name LIKE ?", "%#{lifecycle_name}%"])
      end
      if lifecycle
        project.lifecycle_object = lifecycle
      else
        project.lifecycle_object = Lifecycle.first
      end
      project.save
    end

    wp = Project.find_by_name(workpackage_name, :conditions=>["project_id=?",project.id])
    if not wp
      wp = Project.create(:name=>workpackage_name)
      wp.workstream = request.workstream
      wp.brn        = brn
      wp.project_id = project.id
      lifecycle_name = request.lifecycle_name_for_request_type()
      lifecycle = nil
      if lifecycle_name
        lifecycle = Lifecycle.find(:first, :conditions => ["name LIKE ?", "%#{lifecycle_name}%"])
      end
      if lifecycle
        wp.lifecycle_object = lifecycle
      else
        wp.lifecycle_object = Lifecycle.first
      end      
      wp.save
    end

    request.project_id = wp.id
    request.save
    project.add_responsible_from_rmt_user(request.assigned_to) if request.assigned_to != ""
    render(:text=>"saved")
  end

  def associate
    request = Request.find(params[:id].to_i)
    if request.project.add_responsible_from_rmt_user(request.assigned_to)
      render(:text=>"")
    else
      render(:text=>"Error. Is the rmt_user declared for this user ?")
    end
  end

  def add_to_mine
    Project.find(params[:id]).add_responsible(current_user)
    render(:nothing=>true)
  end

  def remove_from_mine
    Project.find(params[:id]).responsibles.delete(current_user)
    render(:nothing=>true)
  end

  def mark_as_read
    p           = Project.find(params[:id])
    p.read_date = Time.now
    p.save
    render(:nothing=>true)
  end

  def cut
    session[:cut]       = params[:id]
    session[:action_cut]  = nil
    session[:status_cut]  = nil
    session[:request_cut] = nil
    render(:nothing => true)
  end

  def cut_status
    session[:status_cut]  = params[:id]
    session[:action_cut]  = nil
    session[:cut]         = nil
    session[:request_cut] = nil
    render(:nothing => true)
  end

  def paste
    timestamps_off
    paste_project if session[:cut]          != nil
    paste_action  if session[:action_cut]   != nil
    paste_request if session[:request_cut]  != nil
    paste_status  if session[:status_cut]   != nil
    timestamps_on
  end

  def paste_project
    to_id   = params[:id].to_i
    cut_id  = session[:cut].to_i
    cut     = Project.find(cut_id)
    from_id = cut.project_id
    if to_id != cut_id and not cut.has_circular_reference?([Project.find(to_id)])
      cut.project_id = to_id
      cut.save
      cut.update_status
      Project.find(from_id).update_status if from_id
    end
    render(:nothing=>true)
  end

  def paste_action
    to_id   = params[:id].to_i
    cut_id  = session[:action_cut].to_i
    cut     = Action.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    render(:nothing=>true)
  end

  def paste_request
    to_id   = params[:id].to_i
    cut_id  = session[:request_cut].to_i
    cut     = Request.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    render(:nothing=>true)
  end

  def paste_status
    to_id   = params[:id].to_i
    cut_id  = session[:status_cut].to_i
    cut     = Status.find(cut_id)
    from_id = cut.project_id
    cut.project_id = to_id
    cut.save
    Project.find(to_id).update_status
    Project.find(from_id).update_status
    render(:nothing=>true)
  end

  def destroy
    p = Project.find(params[:id].to_i)
    if(p.projects.size > 0 or p.has_status or p.has_requests or p.amendments.size > 0 or p.actions.size > 0 or p.notes.size > 0)
      render(:status=>500, :text=>"#{p.full_name} is not empty")
      return
    end
    p.destroy
    render(:nothing=>true)
  end

  def destroy_status
    Status.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  # generate a complete report (to be copy pasted into a Word document)
  def report
    get_projects
    @projects     = @projects.sort_by { |p| [p.supervisor_name, p.workstream, p.name] }
    @supervisors  = Person.find(:all, :conditions=>"is_supervisor=1", :select=>"id, name",:order=>"name")
    #@wps         = @wps.sort_by { |p| [p.workstream, p.full_name] }
    @size         = @projects.size
    @report       = Report.new(Request.all)
    @topics       = Topic.find(:all, :conditions=>"(done=0 or (done=1 and done_date >= '#{Date.today-18.days}')) and private=0", :order=>"done, person_id, id desc")
    render(:layout=>'report')
  end

  # generate an Excel file to summarize projects status
  def summary
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
      get_projects
      saveWps = @wps
      @wps = @wps.sort_by { |w|
        [w.supervisor_name, w.workstream, w.project_name, w.name]
        }
      #@actions    = Action.find(:all, :conditions=>"private=0", :order=>"person_id, creation_date, progress")
      @requests   = Request.find(:all,:conditions=>"status!='assigned' and status!='cancelled' and status!='closed' and status!='removed'", :order=>"status, workstream")
      @risks      = Risk.find(:all, :conditions => "stream_id IS NULL and is_quality=1") #, :conditions=>"", :order=>"status, workstream")
      @risks      = @risks.select { |r| r.project and r.severity > 0}.sort_by {|r|
        raise "no supervisor for #{r.project.full_name}" if !r.project.supervisor
        [r.project.supervisor.name, r.project.full_name, r.severity]
        }
      @stream_risks   = Risk.find(:all, :conditions => "stream_id IS NOT NULL and is_quality=1") 
      @stream_risks   = @stream_risks.select { |r| r.severity > 0}.sort_by {|r|
        [r.stream.name, r.severity]
        }

      @topics     = Topic.find(:all,  :conditions=>"private=0", :order=>"done, person_id, id desc")
      if @wps.size > 0
        @amendments   = Amendment.find(:all, :conditions=>"project_id in (#{@wps.collect{|p| p.id}.join(',')})", :order=>"done_date DESC, done ASC, duedate ASC")
      else
        @amendments   = []
      end

      date = Date.today-((Date.today().wday+6).days)

      wps          = Request.find(:all, :conditions=>["total_csv_category >= ?", date], :order=>"workstream, project_id, total_csv_category")
      wps.each { |r| r.reporter = "WP change" }
      complexities = Request.find(:all, :conditions=>["total_csv_severity >= ?", date], :order=>"workstream, project_id, total_csv_severity")
      complexities.each { |r| r.reporter = "Complexity change" }
      news         = Request.find(:all, :conditions=>["status_new >= ?", date], :order=>"workstream, project_id, status_new")
      news.each { |r| r.reporter = "New" }
      performed    = Request.find(:all, :conditions=>["status_performed >= ?", date], :order=>"workstream, project_id, status_performed")
      performed.each { |r| r.reporter = "Performed" }
      closed       = Request.find(:all, :conditions=>["status_closed >= ?", date], :order=>"workstream, project_id, status_closed")
      closed.each { |r| r.reporter = "Closed" }
      @week_changes = wps + complexities + news + performed + closed

      # STREAMS REVIEW BEGIN
      stream                = Stream.find(:all)
      @review_types         = ReviewType.find(:all)
      @stream_width_array   = ["100","60","100","100","100"]
      @stream_column_array  = ["workstream","stream","green_project", "amber_project", "red_project"]
      @stream_columns_content = Array.new

      @review_types.each { |rt|
        @stream_width_array.push('200')
        @stream_column_array.push(rt.title)
      }

      stream.each do |s|
        stream_params_array = Hash.new
        stream_params_array["workstream"]     = s.workstream.name
        stream_params_array["stream"]         = s.name
        stream_params_array["green_project"]  = s.get_total_green_projects.to_s
        stream_params_array["amber_project"]  = s.get_total_amber_projects.to_s
        stream_params_array["red_project"]    = s.get_total_red_projects.to_s

        @review_types.each do |rt|
          last_review = StreamReview.first(:conditions => ["stream_id = ? and review_type_id = ?",s.id ,rt.id], :order => "created_at DESC")
          if last_review
            stream_params_array[rt.title] = last_review.text
          else
            stream_params_array[rt.title] = 0
          end
        end
        @stream_columns_content.push(stream_params_array)
      end
      # STREAMS REVIEW END

      # SPIDERS EXPORT
      axes            = PmTypeAxe.get_sorted_axes
      @spidersWidth   = Array.new << 50 << 50 << 50
      for i in 0..axes.count
        @spidersWidth << 50
        @spidersWidth << 50
      end
      @spidersColumns  = Array.new << "Project" << "Workpackage" << "Milestone"
      axes.each do |a|
        @spidersColumns << a.title + " Average"
        @spidersColumns << a.title + " Average Ref"
      end
      @spidersLines    = Spider.spider_export_by_projects_and_milestones(saveWps)
      # SPIDERS EXPORT END

      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="Summary.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
    end
  end

  def nb_of_wps_with_status(c,s)
    @wps.select{ |w| w.workstream==c and w.get_status.status==s}.size.to_s
  end

  def stats_for_center(c)
    #[Workstream.find_by_name(c), nb_of_wps_with_status(c,3), nb_of_wps_with_status(c,2), nb_of_wps_with_status(c,1), nb_of_wps_with_status(c,0)]
    [c, nb_of_wps_with_status(c.name,3), nb_of_wps_with_status(c.name,2), nb_of_wps_with_status(c.name,1), nb_of_wps_with_status(c.name,0)]
  end

  # generate an Excel file for Workstream reporting
  def ws_reporting
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
      get_projects

      @centers = Workstream.all()
      @centers = @centers.map { |c| stats_for_center(c) }

      @wps = @wps.select{ |w| w.get_status.status > 0}.sort_by { |w|
        [w.workstream, w.project_name, w.name]
        }

      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="WS_Reporting.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br/>#{e.backtrace.join("<br/>")}")
    end
  end

  def week_changes
    date = Date.today()-7.days
    # date = "2011-03-15"
    @wps          = Request.find(:all, :conditions=>["total_csv_category >= ?", date], :order=>"workstream, project_id, total_csv_category")
    @complexities = Request.find(:all, :conditions=>["total_csv_severity >= ?", date], :order=>"workstream, project_id, total_csv_severity")
    @news         = Request.find(:all, :conditions=>["status_new >= ?", date], :order=>"workstream, project_id, status_new")
    @performed    = Request.find(:all, :conditions=>["status_performed >= ?", date], :order=>"workstream, project_id, status_performed")
    @closed       = Request.find(:all, :conditions=>["status_closed >= ?", date], :order=>"workstream, project_id, status_closed")
  end


  # Change is_running status

  def stop
    id = params[:id]
    project = Project.find(id)
    if(project)
      project.is_running = 0
      project.save
    end
    render(:nothing => true)
  end

  def start
    id = params[:id]
    project = Project.find(id)
    if(project)
      project.is_running = 1
      project.save
    end
    redirect_to :action=>:show, :id=>project.id
  end

  # Check if the project is just setted to "is_qr_qwr". If yes, change the comments of milestones
  def check_qr_qwr_activated(project,old_is_qr_qwr)
    if project.is_qr_qwr and !old_is_qr_qwr and project.is_running
      project.milestones.each do |m|
        m.comments = "Support QR-QWR"
        m.save
      end
    end
  end

  # Check if the project is just setted to "is_qr_qwr". If Yes, create a WlLine for the person concerned
  def check_qr_qwr_pdc(project)
    # If the project is qr_qwr activated
    if (project.is_qr_qwr && project.is_running && project.qr_qwr_id != nil && project.qr_qwr_id != 0)
      # Check if the line is already created for the qr_qwr
      qr_qwr = Person.find(project.qr_qwr_id)
      if qr_qwr
        wl_line = WlLine.first(:conditions=>["person_id = ? and project_id = ?",qr_qwr.id.to_s, project.id.to_s])
        if !wl_line
          WlLine.create(:name=>"[QR_QWR] "+project.full_name, :request_id=>nil, :person_id=>qr_qwr.id, :wl_type=>WL_LINE_QR_QWR_QS, :project_id=>project.id)
          WlLine.create(:name=>"[QR_QWR] "+project.full_name, :request_id=>nil, :person_id=>qr_qwr.id, :wl_type=>WL_LINE_QR_QWR_SPIDER, :project_id=>project.id)
        end
      end
    end
  end

  def status_list_form
        @project = Project.find(params[:id])
  end


  # -
  # Milestones structure management
  # -
  def milestones_edit
    project_id    = params[:id]
    @project      = Project.find(:first, :conditions => ["id = ?", project_id])
    @warning      = params[:warning]

    @lifecycles   = Lifecycle.find(:all, :conditions => ["is_active = 1"]).map{|l| [l.name, l.id]}
    @milestones_name = MilestoneName.get_active_sorted.map{|m| [m.title, m.id]}
    @milestones_name_multiple = MilestoneName.get_active_sorted.select { |m| m.multiple_creation == true }.map{|m| m.id}

    # Milestones name hash to link milestone <=> milestones name
    @milestones_limit_names = ""
    @milestones_name_hash   = Hash.new
    @milestones_name.each do |m_name|
      @milestones_name_hash[m_name[0]] = m_name[1]
    end
  end

  def lifecycle_change
    project_id    = params[:project_id]
    lifecycle_id  = params[:lifecycle_id]
    project       = Project.find(:first, :conditions => ["id = ?", project_id])
    lifecycle     = Lifecycle.find(:first, :conditions => ["id = ?", lifecycle_id])
    has_data      = false

    if lifecycle_id and project
      
      project.sorted_milestones.each do |m|
        if m.has_data?
          has_data = true
        end
      end

      if has_data == false
        # Change lifecycle
        project.lifecycle = lifecycle_id
        project.lifecycle_object = lifecycle
        project.save
        # Delete previous milestone
        Milestone.destroy_all("project_id = #{project_id}")
        # Generate new milestones
        project.check(true)
      end
    end

    if has_data
      redirect_to :action=>:milestones_edit, :id=>project_id, :warning=>"Lifecycle can't be modified because some milestones have data. Delete all milestone data."
    else
      redirect_to :action=>:milestones_edit, :id=>project_id
    end
  end

  def create_sibling
    project_id    = params[:project_id]
    lifecycle_id  = params[:lifecycle_id]
    project       = Project.find(:first, :conditions => ["id = ?", project_id])
    lifecycle     = Lifecycle.find(:first, :conditions => ["id = ?", lifecycle_id])
    
    if lifecycle_id and project
      new_project   = Project.new
      new_project.create_sibling(project)
      new_project.lifecycle = lifecycle_id
      new_project.lifecycle_object = lifecycle
      new_project.save
    end

    redirect_to :action=>:show, :id=>new_project.id

  end

  # @param milestones = Sorted array (on index order) of milestones id
  def milestones_order_change
    milestones_order = params[:milestones]
    if milestones_order
      index_order = 1
      milestones_order.each do |m|
        milestone_object = Milestone.find(:first, :conditions => ["id = ?", m.to_s])
        if milestone_object
          milestone_object.index_order = index_order
          milestone_object.save
        end
        index_order += 1
      end
    end
    render(:nothing=>true)
  end

  def milestones_name_change
      milestone_id        = params[:milestone_id]
      milestone_name_id   = params[:milestone_name_id]

      milestone       = Milestone.find(:first, :conditions => ["id = ?", milestone_id])
      milestone_name  = MilestoneName.find(:first, :conditions => ["id = ?", milestone_name_id])

      warning = nil
      if milestone and milestone_name
        has_data = milestone.has_data?
        if has_data == false
          milestone.name = milestone_name.title
          milestone.save
        else
          warning = "Milestone can't be modified while it has data."
        end
      end

      if warning != nil
        render(:text=>warning)
      else
        render(:nothing=>true)
      end
  end

  def milestone_virtual_name_change
      milestone_id        = params[:milestone_id]
      milestone_name      = params[:milestone_name]
      milestone_to_export = params[:to_export]
      milestone           = Milestone.find(:first, :conditions => ["id = ?", milestone_id])

      warning = nil
      if milestone and milestone_name
        # Milestone name
        if milestone.name != milestone_name
          has_data = milestone.has_data?
          if has_data == false
            milestone.name = milestone_name
            milestone.save
          else
            warning = "Milestone can't be modified while it has data."
          end
        end

        # Milestone To export
        if milestone_to_export and milestone.to_export != milestone_to_export
          milestone.to_export = milestone_to_export
          milestone.save
        end
      end

      if warning != nil
        render(:text=>warning)
      else
        render(:nothing=>true)
      end
  end

  def milestone_is_virtual_change
    milestone_id          = params[:milestone_id]
    milestone_is_virtual  = params[:is_virtual]
    milestone             = Milestone.find(:first, :conditions => ["id = ?", milestone_id])

    warning = nil
    if milestone and milestone_is_virtual
      has_data = milestone.has_data?
      if has_data == false
        milestone.is_virtual = milestone_is_virtual
        milestone.save
      else
        warning = "Milestone can't be modified while it has data."
      end
    end

    if warning != nil
      render(:text=>warning)
    else
      render(:nothing=>true)
    end
  end

  def add_new_milestone
    project_id        = params[:project_id]
    milestone_name_id = params[:new_milestone]
    milestone_count   = params[:new_milestone_count]

    project         = Project.find(:first, :conditions => ["id = ?", project_id])
    milestone_name  = MilestoneName.find(:first, :conditions => ["id = ?", milestone_name_id])

    if project
      # Max order index
      max_index_order = 0
      project.sorted_milestones.each do |m|
        if m.index_order > max_index_order
          max_index_order = m.index_order
        end
      end

      i = 0
      while i < milestone_count.to_i
        # Create
        new_milestone = Milestone.new
        new_milestone.project = project
        if milestone_name
          new_milestone.name = milestone_name.title
        else
          new_milestone.name = project.lifecycle_object.lifecycle_milestones.find(:first).milestone_name.title
        end
        new_milestone.index_order = max_index_order + 1
        new_milestone.status = -1
        new_milestone.is_virtual = false
        new_milestone.comments = ""
        new_milestone.save

        # Update index
        max_index_order = max_index_order + 1
        i = i + 1
      end
    end
    redirect_to :action=>:milestones_edit, :id=>project_id
  end

  def delete_milestone
    milestone_id  = params[:milestone_id]
    milestone     = Milestone.find(:first, :conditions => ["id = ?", milestone_id])
    project_id    = milestone.project_id
    has_data      = false

    if milestone
      has_data = milestone.has_data?
      if has_data == false
        milestone.destroy
      end
    end
    
    if has_data == false
      redirect_to :action=>:milestones_edit, :id=>project_id
    else
      redirect_to :action=>:milestones_edit, :id=>project_id, :warning=>"Milestone can't be deleted while it has data. Delete all milestone data to be able to delete the milestone."
    end
  end
  # - 

private

  def get_status_progress
    date = Hash.new
    for center in ['Total', 'EA', 'EI', 'EV', 'EDE', 'EDG', 'EDS', 'EDY', 'EDC', 'EM', 'EMNB', 'EMNC']
      date[center] = Hash.new
      month_loop(5,2010) { |to|
        date[center][to] = Array.new
        Project.find(:all).each { |p|
          next if not p.open_requests.size > 0 or not p.has_status or (center != 'Total' and p.workstream != center)
          last_status = p.get_status(to)
          date[center][to] << last_status
          }
        }
    end
    date
  end

  def timestamps_off
    Project.record_timestamps = false
    Status.record_timestamps  = false
    Action.record_timestamps  = false
    Request.record_timestamps = false
  end

  def timestamps_on
    Project.record_timestamps = true
    Status.record_timestamps  = true
    Action.record_timestamps  = true
    Request.record_timestamps = true
  end

  def get_projects
    # Text filtering
    if session[:project_filter_text] != "" and session[:project_filter_text] != nil
      @wps = Project.get_projects_with_text(session[:project_filter_text], false)
      return
    end
    cond_wps = []
    cond_wps << "workstream in #{session[:project_filter_workstream]}" if session[:project_filter_workstream] != nil
    cond_wps << "last_status in #{session[:project_filter_status]}" if session[:project_filter_status] != nil
    cond_wps << "supervisor_id in #{session[:project_filter_supervisor]}" if session[:project_filter_supervisor] != nil
    cond_wps << "suite_tag_id in #{session[:project_filter_suiteTags]}" if session[:project_filter_suiteTags] != nil
    cond_wps << "project_people.person_id in #{session[:project_filter_qr]}" if session[:project_filter_qr] != nil
    cond_wps << "is_running = 1"
    cond_wps << "projects.project_id IS NOT NULL"

    @wps = Project.find(:all, :joins => ["LEFT OUTER JOIN project_people ON project_people.project_id = projects.id"], :conditions=>cond_wps.join(" and "), :group => "projects.id")
  end

  def get_projects_without_wps
    if session[:project_filter_text] != "" and session[:project_filter_text] != nil
      @projects = Project.get_projects_with_text(session[:project_filter_text], true)
      return
    end

    cond_projects = []
    if session[:project_filter_workstream] != nil
      cond_projects << "(projects.workstream in #{session[:project_filter_workstream]} or childs.workstream in #{session[:project_filter_workstream]})"
    end
    if session[:project_filter_status] != nil
      cond_projects << "(projects.last_status in #{session[:project_filter_status]} or childs.last_status in #{session[:project_filter_status]})"
    end
    if session[:project_filter_supervisor] != nil
      cond_projects << "(projects.supervisor_id in #{session[:project_filter_supervisor]} or childs.supervisor_id in #{session[:project_filter_supervisor]})"
    end
    if session[:project_filter_suiteTags] != nil
      cond_projects << "(projects.suite_tag_id in #{session[:project_filter_suiteTags]} or childs.suite_tag_id in #{session[:project_filter_suiteTags]})"
    end
    if session[:project_filter_qr] != nil
      cond_projects << "(project_people.person_id in #{session[:project_filter_qr]} or childs_pp.person_id in #{session[:project_filter_qr]})"
    end
    
    cond_projects << "(projects.project_id is null)"

    @projects = Project.find(:all, :joins => ["LEFT OUTER JOIN projects as childs ON childs.project_id = projects.id","LEFT OUTER JOIN project_people ON project_people.project_id = projects.id", "LEFT OUTER JOIN project_people as childs_pp ON childs_pp.project_id = childs.id"],
                                    :conditions=>cond_projects.join(" and "),
                                    :group => "projects.id")
  end

  def no_responsible(p)
    p.active_requests.map { |r| r.assigned_to }.uniq.each { |name|
      next if name == ""
      return true if not p.responsibles.include?(Person.find_by_rmt_user(name))
      }
    return false
  end

  def find_missing_project_person_associations
    Project.all.select { |p|
      no_responsible(p)
      }
  end

  def get_risk_status_string
    raise "@project must be defined" if not @project
    @risks = "Risks:<br/>"
    #r.severity
    for r in @project.open_quality_risks.find(:all,:order=>"probability*impact desc")
      bgcolor = "#AFA"
      if r.probability>=4 or r.severity>=3
      	bgcolor = r.get_severity_color
      end
      @risks += "<span style='background-color:#{bgcolor};'>#{r.context} => #{r.risk} (#{r.consequence}) [Criticality => #{r.severity}]</span><br/>"
    end
    @risks
  end

end

