require 'lib/csv_ci'
require 'lib/csv_backlog'
class CiProjectsController < ApplicationController

	layout 'ci'

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
      p.justification_airbus_retard = nil
      delay.save
    end
    if old_p.sqli_date_alert == 1 and p.sqli_date_alert == 0
      delay = CiProjectDelay.new
      delay.ci_project_id = p.id
      delay.title = "SQLI validation date"
      delay.justification = p.justification_sqli_retard
      delay.new_date = p.sqli_validation_date
      p.justification_sqli_retard = nil
      delay.save
    end
    if old_p.deployment_date_alert == 1 and p.deployment_date_alert == 0
      delay = CiProjectDelay.new
      delay.ci_project_id = p.id
      delay.title = "Deployment date"
      delay.justification = p.justification_deployment_retard
      delay.new_date = p.deployment_date
      p.justification_deployment_retard = nil
      delay.save
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
  end

end
