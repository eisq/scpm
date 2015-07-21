require 'lib/csv_ci'
require 'lib/csv_backlog'
class CiProjectsController < ApplicationController

	layout 'ci'
  Delays = Struct.new(:ci_project, :ci_delay)
  Date_ccb = Struct.new(:week, :date_type)
  Timeline_date = Struct.new(:date_string, :date_week, :date_th_span, :date_td_span)
  Timeline_project = Struct.new(:id, :name, :responsible, :validator, :start_date, :status, :status_color, :validation_date_delay, :validation_date_delay_color, :deployment_date_delay, :deployment_date_delay_color, :planning_external_validation, :start_date_week, :validation_date_week, :deployment_date_week, :in_progress, :link_type, :link_to, :id_start_to_show_week, :id_finish_to_show_week, :status_sort)

	def index
  	redirect_to :action=>:mine
	end

  def mine
    #verif
    @projectsopened = CiProject.find(:all, :conditions=>["assigned_to=? and (status!='Closed' and status!='Rejected' and status!='Delivered')", current_user.rmt_user]).sort_by {|p| [p.order]}
    @projectsclosed = CiProject.find(:all, :conditions=>["assigned_to=? and (status='Closed' or status='Delivered' or status='Rejected')", current_user.rmt_user]).sort_by {|p| [p.order]}
  end

  def alerts
    @projects = CiProject.find(:all, :conditions=>["assigned_to=? and (sqli_date_alert=1 or airbus_date_alert=1 or deployment_date_alert=1) and (status!='Closed' and status!='Rejected' and status!='Delivered')", current_user.rmt_user]).sort_by {|p| [p.order]}
  end

  def create_ci
    @project = CiProject.new
    @project.submission_date = DateTime.now
    @project.reporter = current_user.rmt_user

    @select_ci_type = CiProject.get_ci_type
    @select_stage = CiProject.get_stage
    @select_category = CiProject.get_category
    @select_severity = CiProject.get_severity
    @select_reproductibility = CiProject.get_reproductibility
    @select_status = CiProject.get_status
    @select_visibility = CiProject.get_visibility
    @select_priority = CiProject.get_priority
    #@select_issue_origin = CiProject.get_issue_origin
    #@select_lot = CiProject.get_lot
    @select_entity = CiProject.get_entity
    @select_domain = CiProject.get_domain
    @select_origin = CiProject.get_origin
    @select_dev_team = CiProject.get_dev_team
    #@select_ci_objectives_2014 = CiProject.get_ci_objectives_2014
    #@select_level_of_impact = CiProject.get_level_of_impact
    @select_deployment = CiProject.get_deployment
    @select_ci_objectives_2015 = CiProject.get_ci_objectives_2015
  end

  def all
    #verif
    @projects = CiProject.find(:all).sort_by {|p| [p.order||0, p.assigned_to||'']}
    @last_import = CiImport.find(:last)
  end

  def late
    @toassign = CiProject.find(:all, :conditions=>"assigned_to='' and status!='Closed' and status!='Delivered' and status!='Rejected'", :order=>"sqli_validation_date desc")
    @sqli     = CiProject.find(:all, :conditions=>"status='Accepted' or status='Assigned'", :order=>"sqli_validation_date desc")
    @todeploy = CiProject.find(:all, :conditions=>"status='Validated'", :order=>"sqli_validation_date desc")
    @airbus   = CiProject.find(:all, :conditions=>"status='Verified'", :order=>"sqli_validation_date desc")
  end

  def verif
    CiProject.all.each { |p| 
      p.sqli_validation_date   = p.sqli_validation_date_objective if !p.sqli_validation_date
      p.airbus_validation_date_review = p.airbus_validation_date_objective if !p.airbus_validation_date_review
      p.deployment_date        = p.deployment_date_objective if !p.deployment_date
      p.save
    }
  end

  def report
    @sqli     = CiProject.find(:all, :conditions=>"deployment='External' and visibility='Public' and (status='Accepted' or status='Assigned')", :order=>"sqli_validation_date")
    @airbus   = CiProject.find(:all, :conditions=>"deployment='External' and visibility='Public' and (status='Verified')", :order=>"airbus_validation_date_review")
  end

  #Mantis vers BAM
  def do_upload
    post = params[:upload]
    redirect_to '/ci_projects/index' and return if post.nil? or post['datafile'].nil?    
    name =  post['datafile'].original_filename
    directory = "public/data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(post['datafile'].read) }
    report = CsvCiReport.new(path)
    begin
      report.parse
      # transform the Report into a CiProject
      report.projects.each { |p|
        # get the id if it exist, else create it
        filter = DateTime.strptime('14/09/11 12:00', '%Y/%m/%d %H:%M') #we will manage only CIs started from this date.
        if (p.stage and p.stage == "Continuous Improvement" and DateTime.strptime(p.submission_date, '%d/%m/%Y %H:%M') >= filter) #DateTime.strptime('2013/09/01 16:00', '%Y/%m/%d %H:%M')))
          ci = CiProject.find_by_external_id(p.external_id)
          #Si on ne trouve pas de CI correspondant dans la base
          if !ci
            #On check si ce n'est pas un CI créé par le BAM et dont il faut mettre à jour l'id. exemple:
            #id venant de mantis : 0000615 [10001]
            #id du même CI enregistré dans la base BAM : 10001 -> car il a été créé dans le BAM en premier
            id_bam_creation = CiProject.extract_bam_external_id(p.external_id)
            if id_bam_creation != 0
              ci = CiProject.find_by_external_id(id_bam_creation)
            else
              ci = CiProject.create(:external_id=>p.external_id)
            end
          end

          if ci
            #update only fields not potentially updated by BAM, to not erase data changed by users directly into the BAM
            ci.update_attribute('internal_id', p.internal_id)
            ci.update_attribute('external_id', p.external_id)
            ci.update_attribute('ci_type', p.ci_type)
            ci.update_attribute('stage', p.stage)
            ci.update_attribute('category', p.category)
            ci.update_attribute('severity', p.severity)
            ci.update_attribute('reproductibility', p.reproductibility)
            ci.update_attribute('status', p.status)
            ci.update_attribute('submission_date', p.submission_date)
            ci.update_attribute('reporter', p.reporter)
            ci.update_attribute('last_update_person', p.last_update_person)
            ci.update_attribute('assigned_to', p.assigned_to)
            ci.update_attribute('priority', p.priority)
            ci.update_attribute('visibility', p.visibility)
            ci.update_attribute('detection_version', p.detection_version)
            ci.update_attribute('fixed_in_version', p.fixed_in_version)
            ci.update_attribute('status_precisions', p.status_precisions)
            ci.update_attribute('resolution_charge', p.resolution_charge)
            ci.update_attribute('duplicated_id', p.duplicated_id)
            ci.update_attribute('additional_informations', p.additional_informations)
            ci.update_attribute('taking_into_account_date', p.taking_into_account_date)
            ci.update_attribute('realisation_date', p.realisation_date)
            ci.update_attribute('realisation_author', p.realisation_author)
            ci.update_attribute('delivery_date', p.delivery_date)
            ci.update_attribute('reopening_date', p.reopening_date)
            ci.update_attribute('issue_origin', p.issue_origin)
            ci.update_attribute('detection_phase', p.detection_phase)
            ci.update_attribute('injection_phase', p.injection_phase)
            ci.update_attribute('real_test_of_detection', p.real_test_of_detection)
            ci.update_attribute('theoretical_test_of_detection', p.theoretical_test_of_detection)
            ci.update_attribute('iteration', p.iteration)
            ci.update_attribute('lot', p.lot)
            ci.update_attribute('team', p.team)
            ci.update_attribute('domain', p.domain)
            ci.update_attribute('num_req_backlog', p.num_req_backlog)
            ci.update_attribute('origin', p.origin)
            ci.update_attribute('output_type', p.output_type)
            ci.update_attribute('deliverables_list', p.deliverables_list)
            ci.update_attribute('dev_team', p.dev_team)
            ci.update_attribute('deployment', p.deployment)
            ci.update_attribute('airbus_responsible', p.airbus_responsible)
            ci.update_attribute('ci_objective_2012', p.ci_objective_2012)
            ci.update_attribute('ci_objectives_2013', p.ci_objectives_2013)
            ci.update_attribute('deliverable_folder', p.deliverable_folder)
            ci.update_attribute('specification_date', p.specification_date)
            ci.update_attribute('specification_date_objective', p.specification_date_objective)
            ci.update_attribute('sqli_validation_responsible', p.sqli_validation_responsible)
            ci.update_attribute('ci_objectives_2014', p.ci_objectives_2014)
            ci.update_attribute('linked_req', p.linked_req)
            ci.update_attribute('level_of_impact', p.level_of_impact)
            ci.update_attribute('impacted_mnt_process', p.impacted_mnt_process)
            ci.update_attribute('path_backlog', p.path_backlog)
            ci.update_attribute('path_sfs_airbus', p.path_sfs_airbus)
            ci.update_attribute('item_type', p.item_type)
            ci.update_attribute('verification_date_objective', p.verification_date_objective)
            ci.update_attribute('verification_date', p.verification_date)
            ci.update_attribute('request_origin', p.request_origin)
            ci.update_attribute('issue_history', p.issue_history)
            ci.update_attribute('ci_objectives_2015', p.ci_objectives_2015)

            ci.save
          end
        end
      }

      ci_import = CiImport.new
      ci_import.import_type = "mantis"
      ci_import.import_author = current_user.rmt_user
      ci_import.save

      redirect_to '/ci_projects/all'
    rescue Exception => e
      render(:text=>e)
    end
  end

  #Backlog vers BAM
  def do_upload_backlog
    post = params[:upload]
    redirect_to '/ci_projects/index' and return if post.nil? or post['datafile'].nil?    
    name =  post['datafile'].original_filename
    directory = "public/data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(post['datafile'].read) }
    report = CsvBacklogReport.new(path)
    begin
      report.parse
      report.projects.each { |p|
        if (p.ticket_or_ci_ref != nil and p.ticket_or_ci_ref != "" and p.id != nil and p.id != "")
          cis = p.ticket_or_ci_ref.split(" ")
          cis.each { |c|
            id_ci = c.split("#")
            if id_ci.first == "CI"
              ci = CiProject.find_by_external_id(id_ci.last.to_i)
              if ci.deployment_date.to_s != p.deployment_date.to_s
                ci.update_attribute('deployment_date_alert', 1)
              end
              if ci.airbus_validation_date.to_s+"" != p.acceptance_date.to_s+""
                ci.update_attribute('airbus_date_alert', 1)
              end
              ci.update_attribute('num_req_backlog', p.id)
              ci.save
            end
          }
        end
      }

      ci_import = CiImport.new
      ci_import.type = "backlog"
      ci_import.author = current_user.rmt_user
      ci_import.save

      redirect_to '/ci_projects/all'
    rescue Exception => e
      render(:text=>e)
    end
  end

  def edit
    id = params[:id]
    @project = CiProject.find(id)
    @qr_list = Person.find(:all, :conditions=>["is_supervisor = 0 and has_left = 0"], :order=>"name")
    @justifications = CiProject.get_justifications
    @links = CiProjectLink.get_links(@project.id)
  end

  def edit_report
    id = params[:id]
    @project = CiProject.find(id)
  end

  def update
    p = CiProject.find(params[:id])
    old_p = CiProject.find(params[:id])

    p.update_attributes(params[:project])

    link = CiProjectLink.new(params[:project_link])
    if link.title and link.title != "" and link.second_ci_project_id and link.second_ci_project_id != ""
      CiProject.find(:all).each do |ci_project_temp|
        if ci_project_temp.extract_mantis_external_id == link.second_ci_project_id
          link.second_ci_project_id = ci_project_temp.id
          link.first_ci_project_id = p.id
          link.save
        break
        end
      end
    end

    validators = siglum = responsible = ""

    responsible = p.sqli_validation_responsible
    persons = Person.find(:all)
    persons.each { |person|
      if (person.name == responsible)
        siglum += person.rmt_user + "@sqli.com,"
      end
    }

    validators = siglum + APP_CONFIG['ci_date_to_validate_destination'] #-> modifier dans config.yml : "jmondy@sqli.com,ngagnaire@sqli.com,dadupont@sqli.com"

    #if a date has changed, an alert is raised
    if (old_p.sqli_validation_date != p.sqli_validation_date)
      p.sqli_date_alert = 1
      date_validation_mail(validators, p, p.justification_sqli_retard)
    end
    if (old_p.airbus_validation_date != p.airbus_validation_date)
      p.airbus_date_alert = 1
      date_validation_mail(validators, p, p.justification_airbus_retard)
    end
    if (old_p.deployment_date != p.deployment_date)
      p.deployment_date_alert = 1
      date_validation_mail(validators, p, p.justification_deployment_retard)
    end

    #if a date is committed, the delay and it's justification is recorded
    if old_p.airbus_date_alert == 1 and p.airbus_date_alert == 0
      delay = CiProjectDelay.new
      delay.ci_project_id = p.id
      delay.title = "Airbus validation date"
      delay.justification = p.justification_airbus_retard
      delay.new_date = p.airbus_validation_date
      delay.old_date = old_p.airbus_validation_date
      p.justification_airbus_retard = nil
      p.airbus_commit_author = current_user.rmt_user
      delay.save
    end
    if old_p.sqli_date_alert == 1 and p.sqli_date_alert == 0
      delay = CiProjectDelay.new
      delay.ci_project_id = p.id
      delay.title = "SQLI validation date"
      delay.justification = p.justification_sqli_retard
      delay.new_date = p.sqli_validation_date
      delay.old_date = old_p.sqli_validation_date
      p.justification_sqli_retard = nil
      p.sqli_commit_author = current_user.rmt_user
      delay.save
    end
    if old_p.deployment_date_alert == 1 and p.deployment_date_alert == 0
      delay = CiProjectDelay.new
      delay.ci_project_id = p.id
      delay.title = "Deployment date"
      delay.justification = p.justification_deployment_retard
      delay.new_date = p.deployment_date
      delay.old_date = old_p.deployment_date
      p.justification_deployment_retard = nil
      p.deployment_commit_author = current_user.rmt_user
      delay.save
    end

    if p.sqli_validation_done == 1
      p.sqli_date_alert = 0
    end
    if p.airbus_validation_done == 1
      p.airbus_date_alert = 0
    end
    if p.deployment_done == 1
      p.deployment_date_alert = 0
    end

    p.save
    redirect_to "/ci_projects/show/"+p.id.to_s
  end

  def update_report
    p = CiProject.find(params[:id])
    previous_report_attribute = p.report
    p.last_update = Time.now
    p.last_update_person = current_user.rmt_user
    p.update_attributes(params[:project])
    p.update_attribute('previous_report', previous_report_attribute)
    redirect_to "/ci_projects/show/"+p.id.to_s
  end

  def do_create_ci
    extracted_external_id = default_external_id = last_external_id = 0
    projects = CiProject.find(:all)
    projects.each { |t|
      extracted_external_id = t.extract_bam_external_id
      if ((extracted_external_id > 0) and (extracted_external_id > last_external_id))
          last_external_id = extracted_external_id
      elsif ((extracted_external_id == 0) and (t.external_id.to_i > last_external_id))
          last_external_id = t.external_id.to_i
      end
    }

    p = CiProject.new(params[:project])
    #on va check l'external_ID créé par le BAM, la première occurence doit être 10000, si ce n'est pas le cas, le créé.
    if last_external_id < 9999
      last_external_id = 9999
    end
    p.external_id = (last_external_id + 1).to_s

    p.to_implement = 1
    p.reporter = current_user.rmt_user

    p.save
    redirect_to "/ci_projects/show/"+p.id.to_s
  end

  def show
    id = params['id']
    @project = CiProject.find(id)
    @delays = CiProjectDelay.find(:all, :conditions=>["ci_project_id = ?", @project.id], :order => "id desc")
    @links = CiProjectLink.get_links(@project.id)
  end

  def mantis_export
    @export_mantis_formula = formula = ""
    @export_mantis_count = 0
    @projects = CiProject.find(:all).sort_by {|p| [p.external_id]}
    @projects.each { |pr|
      #Formule pour mettre à jour les projets existants
      if pr.status!="Closed" and pr.status!="Delivered" and pr.status!="Rejected"
        formula += pr.mantis_formula
        #raise pr.to_implement
        if pr.to_implement == 1
          @export_mantis_count += 1
        end
      end
    }
    @export_mantis_formula = formula
  end

  def mantis_implemented
    @projects = CiProject.find(:all).sort_by {|p| [p.external_id]}
    @projects.each { |p|
      if p.to_implement == 1
        #CiProject.delete(p)
        p.to_implement = 0
      end
      p.save
    }
    redirect_to "/ci_projects/mantis_export"
  end

  def date_validation_mail(validators, project, justification)
      Mailer::deliver_ci_date_change(validators, project, justification)
  end

  def dashboard
    @ci_projects = CiProject.find(:all).sort_by {|p| [p.id]}
    @ci_projects_delays = Array.new
    delays = CiProjectDelay.find(:all)
    delays.each do |del|
      ciproject = CiProject.find(:first, :conditions=>["id = ?", del.ci_project_id])
      delay_struct = Delays.new
      delay_struct.ci_project = ciproject
      delay_struct.ci_delay = del
      @ci_projects_delays << delay_struct
    end
  end

  def delete_link
    id = params['id']
    ci_id = params['ci_id']

    ci_link = CiProjectLink.find(:first, :conditions=>["id = ?", id])
    if ci_link
      ci_link.delete
    end
    
    redirect_to(:action=>'show', :id=>ci_id)
  end

  def timeline
    timeline_projects = Array.new
    CiProject.find(:all, :conditions=>["status <> ? and visibility = ?", "Rejected", "public"]).each do |ci_project|
      if timeline_is_ci_project_visible(ci_project)
        timeline_project = Timeline_project.new # Timeline_project = Struct.new(:id, :name, :responsible, :validator, :start_date, :status, :status_color, :validation_date_delay, :validation_date_delay_color, :deployment_date_delay, :deployment_date_delay_color, :planning_external_validation, :start_date_week, :validation_date_week, :deployment_date_week, :in_progress, :link_type, :link_to, :id_start_to_show_week, :id_finish_to_show_week, :status_sort)
        timeline_project.id = ci_project.extract_mantis_external_id.to_s
        timeline_project.name = ci_project.summary
        timeline_project.responsible = timeline_get_name_responsible(ci_project.assigned_to)
        timeline_project.validator = ci_project.sqli_validation_responsible
        timeline_project.start_date = ci_project.kick_off_date
        timeline_project.status = timeline_get_displayed_status(ci_project.status)
        timeline_project.status_color = timeline_get_color_from_status(ci_project.status)
        timeline_project.validation_date_delay = timeline_get_validation_date_delay_weeks(ci_project)
        timeline_project.validation_date_delay_color = timeline_get_date_delay_color(timeline_project.validation_date_delay)
        timeline_project.deployment_date_delay = timeline_get_deployment_date_delay_weeks(ci_project)
        timeline_project.deployment_date_delay_color = timeline_get_date_delay_color(timeline_project.deployment_date_delay)
        timeline_project.planning_external_validation = timeline_get_planning_external_validation(ci_project.planning_validated)
        timeline_project.start_date_week = timeline_get_week_from_date(ci_project.kick_off_date)
        timeline_project.validation_date_week = timeline_get_validation_date_week(ci_project)
        timeline_project.deployment_date_week = timeline_get_deployment_date_week(ci_project)
        timeline_project.in_progress = timeline_get_ci_in_progress(ci_project)
        timeline_project.link_type = 0 #0 = nothing, 1 = father, 2 = son, 3 = brother
        timeline_project.link_to = 0 #id of the linked ci_project
        timeline_project.id_start_to_show_week = timeline_get_id_start_to_show_week(ci_project)
        timeline_project.id_finish_to_show_week = timeline_get_id_finish_to_show_week(ci_project)
        timeline_project.status_sort = timeline_get_status_sort(ci_project)

        timeline_projects << timeline_project
      end
    end

    #Here we sort the ci_projects to allow the link display in the timeline
    #Links are: Related to, Dependant on, Blocks
    links_bloc = Array.new
    CiProjectLink.find(:all).each do |link|
      first_project_id = CiProject.find(:first, :conditions=>["id = ?", link.first_ci_project_id]).extract_mantis_external_id
      second_project_id = CiProject.find(:first, :conditions=>["id = ?", link.second_ci_project_id]).extract_mantis_external_id

      timeline_project_first_array = timeline_projects.select { |p| p.id.to_i == first_project_id }
      timeline_project_second_array = timeline_projects.select { |p| p.id.to_i == second_project_id }
      timeline_project_first = timeline_project_first_array[0]
      timeline_project_second = timeline_project_second_array[0]

      if timeline_project_first and timeline_project_second
        timeline_projects.delete(timeline_project_first)
        timeline_projects.delete(timeline_project_second)

        case link.title
          when "Related to"
            timeline_project_first.link_type = 3
            timeline_project_first.link_to = timeline_project_second.id
            timeline_project_second.link_type = 3
            timeline_project_second.link_to = timeline_project_first.id
          when "Dependant on"
            timeline_project_first.link_type = 2
            timeline_project_first.link_to = timeline_project_second.id
            timeline_project_second.link_type = 1
          when "Blocks"
            timeline_project_first.link_type = 1
            timeline_project_second.link_type = 2
            timeline_project_second.link_to = timeline_project_first.id
        end

        links_bloc.push(timeline_project_first, timeline_project_second)
      end
    end

    @timeline_projects_sorted = Array.new
    links_bloc.each do |timeline_project_with_link|
      if timeline_project_with_link.link_type == 1
        links_bloc.each do |timeline_project_with_link_son|
          if timeline_project_with_link_son.link_to == timeline_project_with_link.id and timeline_project_with_link_son.link_type == 2
            @timeline_projects_sorted.push(timeline_project_with_link, timeline_project_with_link_son)

            links_bloc.delete(timeline_project_with_link)
            links_bloc.delete(timeline_project_with_link_son)
          end
        end
      elsif timeline_project_with_link.link_type == 2
        links_bloc.each do |timeline_project_with_link_father|
          if timeline_project_with_link.link_to == timeline_project_with_link_father.id and timeline_project_with_link_father.link_type == 1
            @timeline_projects_sorted.push(timeline_project_with_link_father, timeline_project_with_link)

            links_bloc.delete(timeline_project_with_link)
            links_bloc.delete(timeline_project_with_link_father)
          end
        end
      end
    end

    links_bloc.each do |timeline_project_with_link|
      if timeline_project_with_link.link_type == 3
        
        links_bloc.each do |timeline_project_with_link_brother|
          if timeline_project_with_link_brother.link_to == timeline_project_with_link.id and timeline_project_with_link_brother.link_type == 3
            @timeline_projects_sorted.push(timeline_project_with_link, timeline_project_with_link_brother)

            links_bloc.delete(timeline_project_with_link)
            links_bloc.delete(timeline_project_with_link_brother)
          end
        end
      end
    end

    timeline_projects_sort = timeline_projects.sort_by { |n| n.status_sort}
    timeline_projects_sort.each do |timeline_project_to_add|
      @timeline_projects_sorted << timeline_project_to_add
    end
    
    weeks_ccb = Array.new
    ci_timeline_dates = CiTimelineDate.find(:all).each do |ci_timeline_date|
      date = Date_ccb.new # Date_ccb = Struct.new(:week, :date_type)
      date.week = timeline_get_week_from_date(ci_timeline_date.date)
      date.date_type = ci_timeline_date.date_type
      weeks_ccb << date
    end

    @dates = Array.new
    u = -84
    for i in 0..24
      date_th_span = "timeline_th_date_span"
      date_td_span = ""
      span_found = false

      timeline_date = Timeline_date.new #Timeline_date = Struct.new(:date_string, :date_week, :date_th_span, :date_td_span)
      date = Date.today + u
      date_monday = date - (date.cwday-1).days # get monday of the week
      
      # Here it adds a "O" before the date to be more graphical: 07/08/2015 instead of 7/08/2015
      if date_monday.mday < 10
        date_day = "0"+date_monday.mday.to_s
      else
        date_day = date_monday.mday.to_s
      end
      if date_monday.mon < 10
        date_month = "/0"+date_monday.mon.to_s
      else
        date_month = "/"+date_monday.mon.to_s
      end
      date_format = date_day + date_month + "/" + date_monday.year.to_s

      #Here it sets the span of the current week (in yellow)
      if i == 12
        date_th_span = "timeline_th_date_span_today"
        date_td_span = "timeline_td_date_today"
      end

      #Here it sets the td and th span on the row according to CCB date or CCB deployment
      weeks_ccb.each do |week_ccb|
        if week_ccb.week == date.cweek and !span_found
          if week_ccb.date_type == "CCB Date"
            date_th_span = "timeline_th_date_ccb"
            date_td_span = "timeline_td_date_cbb"
            span_found = true
          elsif week_ccb.date_type == "CCB Deployment"
            date_th_span = "timeline_th_date_ccb_deployment"
            date_td_span = "timeline_td_date_ccb_deployment"
            span_found = true
          end
        end
      end

      timeline_date.date_string = date_format
      timeline_date.date_week = date.cweek
      timeline_date.date_th_span = date_th_span
      timeline_date.date_td_span = date_td_span

      @dates << timeline_date
      u += 7
    end

  end

  def timeline_config
    @types = ['CCB Date', 'CCB Deployment']
    @timeline_dates = CiTimelineDate.find(:all)
  end

  def timeline_create_date
    date_type = params[:date_type]
    date = params[:date]
    if date_type and date and date_type != "" and date != ""
      ci_timeline_date = CiTimelineDate.new
      ci_timeline_date.date_type = date_type
      ci_timeline_date.date = date
      ci_timeline_date.save
    end

    redirect_to(:action=>'timeline_config')
  end

  def timeline_delete_date
    id = params[:id]
    timeline_date = CiTimelineDate.find(:first, :conditions=>["id = ?", id])
    if timeline_date
      timeline_date.destroy
    end
    
    redirect_to(:action=>'timeline_config')
  end

  def timeline_get_displayed_status(ci_project_status)
    status = ""

    case ci_project_status
    when "New"
      status = "Waiting Kick-off"
    when "Qualification"
      status = "Waiting Kick-off"
    when "Assigned"
      status = "Running"
    when "Verified"
      status = "Running"
    when "Validated"
      status = "Running"
    when "Delivered"
      status = "Deployed"
    when "Comment"
      status = "On hold"
    end

    return status
  end

  def timeline_get_planning_external_validation(ci_project_planning_validated)
    validation = "No"

    case ci_project_planning_validated
    when true
      validation = "Yes"
    when false
      validation = "No"
    end

    return validation
  end

  def timeline_get_week_from_date(date)
    week = 0

    if date
      date_format = get_date_from_bdd_date(date)
      week = date_format.cweek
    end

    return week
  end

  def timeline_get_deployment_date_week(ci_project)
    week = 0

    if ci_project.deployment_date != nil and ci_project.deployment_date_alert == 0
      week = timeline_get_week_from_date(ci_project.deployment_date)
    else
      week = timeline_get_week_from_date(ci_project.deployment_date_objective)
    end

    return week
  end

  def timeline_get_validation_date_week(ci_project)
    week = 0

    if ci_project.airbus_validation_date != nil and ci_project.airbus_date_alert == 0
      week = timeline_get_week_from_date(ci_project.airbus_validation_date)
    else
      week = timeline_get_week_from_date(ci_project.airbus_validation_date_objective)
    end

    return week
  end

  def timeline_get_ci_in_progress(ci_project)
    in_progress = false

    if ci_project.kick_off_date and (ci_project.airbus_validation_date or ci_project.airbus_validation_date_objective)

      kick_off_date = get_date_from_bdd_date(ci_project.kick_off_date)
      if ci_project.airbus_validation_date != nil
        airbus_validation_date = get_date_from_bdd_date(ci_project.airbus_validation_date)
      else
        airbus_validation_date = get_date_from_bdd_date(ci_project.airbus_validation_date_objective)
      end
      timeline_start_date = Date.today - 84

      if kick_off_date and airbus_validation_date
        if (kick_off_date < timeline_start_date) and (airbus_validation_date > timeline_start_date)
          in_progress = timeline_is_there_validation_and_deployment_dates(ci_project)
        end
      end

    end

    return in_progress
  end

  def get_date_from_bdd_date(bdd_date)
    date_split = bdd_date.to_s.split("-")
    date = Date.new(date_split[0].to_i, date_split[1].to_i, date_split[2].to_i)

    return date
  end

  def timeline_get_validation_date_delay_weeks(ci_project)
    delay_days = delay_days_weeks = 0
    if ci_project.airbus_validation_date and ci_project.airbus_validation_date_objective and ci_project.airbus_date_alert == 0
      delay_days = ci_project.airbus_validation_date - ci_project.airbus_validation_date_objective
      delay_days_weeks = delay_days / 7
      delay_days_weeks = delay_days_weeks.round
    else
      delay_days_weeks = nil
    end

    if delay_days_weeks == 0
      delay_days_weeks = nil
    end

    return delay_days_weeks
  end

  def timeline_get_deployment_date_delay_weeks(ci_project)
    delay_days = delay_days_weeks = 0
    if ci_project.deployment_date and ci_project.deployment_date_objective and ci_project.deployment_date_alert == 0
      delay_days = ci_project.deployment_date - ci_project.deployment_date_objective
      delay_days_weeks = delay_days / 7
      delay_days_weeks = delay_days_weeks.round
    else
      delay_days_weeks = nil
    end

    if delay_days_weeks == 0
      delay_days_weeks = nil
    end

    return delay_days_weeks
  end

  def timeline_is_there_validation_and_deployment_dates(ci_project)
    answer = false

    if (ci_project.airbus_validation_date or ci_project.airbus_validation_date_objective) and (ci_project.deployment_date or ci_project.deployment_date_objective)
      if (ci_project.airbus_validation_date != "" or ci_project.airbus_validation_date_objective != "") and (ci_project.deployment_date != "" or ci_project.deployment_date_objective != "")
        answer = true
      end
    end

    return answer
  end

  def timeline_get_color_from_status(status)
    td_color_style = ""

    case status
    when "New"
      td_color_style = "timeline_td_status_lightblue"
    when "Qualification"
      td_color_style = "timeline_td_status_lightblue"
    when "Assigned"
      td_color_style = "timeline_td_status_blue"
    when "Verified"
      td_color_style = "timeline_td_status_blue"
    when "Validated"
      td_color_style = "timeline_td_status_blue"
    when "Delivered"
      td_color_style = "timeline_td_status_green"
    when "Comment"
      td_color_style = "timeline_td_status_blank"
    end

    return td_color_style
  end

  def timeline_get_date_delay_color(date_delay)
    td_color_style = ""

    if date_delay != nil and date_delay != 0
      td_color_style = "timeline_td_date_delay"
    else
      td_color_style = "timeline_td_date_no_delay"
    end

    return td_color_style
  end

  def timeline_get_id_start_to_show_week(ci_project)
    date_week = 0

    if ci_project.kick_off_date
      kick_off_date = get_date_from_bdd_date(ci_project.kick_off_date)
      kick_off_date_next = kick_off_date + 7
      date_week = kick_off_date_next.cweek
    end

    return date_week
  end

  def timeline_get_id_finish_to_show_week(ci_project)
    date_week = 0

    if ci_project.airbus_validation_date != nil and ci_project.airbus_date_alert == 0
      kick_off_date = get_date_from_bdd_date(ci_project.airbus_validation_date)
      kick_off_date_previous = kick_off_date - 7
      date_week = kick_off_date_previous.cweek
    elsif ci_project.airbus_validation_date_objective != nil
      kick_off_date = get_date_from_bdd_date(ci_project.airbus_validation_date_objective)
      kick_off_date_previous = kick_off_date - 7
      date_week = kick_off_date_previous.cweek
    end
    
    return date_week
  end

  def timeline_is_ci_project_visible(ci_project)
    is_visible = false
    difference_in_days = 100

    if ci_project.deployment_done
      if ci_project.deployment_date != nil and ci_project.deployment_date_alert == 0
        difference_in_days = (Date.today - get_date_from_bdd_date(ci_project.deployment_date)).to_i
      elsif ci_project.deployment_date_objective != nil
        difference_in_days = (Date.today - get_date_from_bdd_date(ci_project.deployment_date_objective)).to_i
      end

      if difference_in_days < 84
        is_visible = true
      end

    else
      is_visible = true
    end

    return is_visible
  end

  def timeline_get_status_sort(ci_project)
    status_sorted = 0

    if ci_project.status
      case ci_project.status
        when "New"
          status_sorted = 4
        when "Qualification"
          status_sorted = 3
        when "Assigned"
          status_sorted = 0
        when "Verified"
          status_sorted = 1
        when "Validated"
          status_sorted = 2
        when "Delivered"
          status_sorted = 5
        when "Comment"
          status_sorted = 6
      end
    end

      return status_sorted
  end

  def timeline_get_name_responsible(rmt_user)
    name = ""

    if rmt_user and rmt_user != ""
      name = Person.find(:first, :conditions=>['rmt_user = ?', rmt_user]).name
    end

    return name
  end

  def sanitize(value)
        value.gsub!(130.chr, "e") # eacute
        value.gsub!(133.chr, "a") # a grave
        value.gsub!(135.chr, "c") # c cedille
        value.gsub!(138.chr, "e") # e grave
        value.gsub!(140.chr, "i") # i flex
        value.gsub!(147.chr, "o") # o flex
        value.gsub!(156.chr, "oe") # oe
        value.gsub!(167.chr, "o") # °
        value.gsub!("é", "e")
        return value
    end

end
