require 'lib/csv_ci'
require 'lib/csv_backlog'
class CiProjectsController < ApplicationController

	layout 'ci'

	def index
  	redirect_to :action=>:mine
	end

  def mine
    #verif
    #@projects = CiProject.find(:all, :conditions=>["assigned_to=?", current_user.rmt_user]).sort_by {|p| [p.order]}
    @projectsopened = CiProject.find(:all, :conditions=>["assigned_to=? and (status!='Closed' and status!='Rejected' and status!='Delivered')", current_user.rmt_user]).sort_by {|p| [p.order]}
    @projectsclosed = CiProject.find(:all, :conditions=>["assigned_to=? and (status='Closed' or status='Delivered' or status='Rejected')", current_user.rmt_user]).sort_by {|p| [p.order]}
  end

  def alerts
    @projects = CiProject.find(:all, :conditions=>["assigned_to=? and (sqli_date_alert=1 or airbus_date_alert=1 or deployment_date_alert=1) and (status!='Closed' and status!='Rejected' and status!='Delivered')", current_user.rmt_user]).sort_by {|p| [p.order]}
  end

  def create_ci
    @project = CiProject.new()
    @project.submission_date = DateTime.now
    @project.reporter = current_user.rmt_user

    @select_type = [['Anomaly', 'Anomaly'], ['Evolution', 'Evolution']]
    @select_stage = [['Continuous Improvement', 'Continuous Improvement']]
    @select_category = [['Autres', 'Autres'], ['Bundle', 'Bundle'], ['Methodo Airbus (GPP, LBIP ...)', 'Methodo Airbus (GPP, LBIP ...)'], ['Methodo Airbus (GPP, LBIP...)', 'Methodo Airbus (GPP, LBIP...)'], ['Project', 'Project']]
    @select_severity = [['minor', 'minor'], ['major', 'major'], ['block', 'block'], ['text', 'text'], ['tweak', 'tweak']]
    @select_reproductibility = [['always', 'always'], ['sometimes', 'sometimes'], ['random', 'random'], ['have not tried', 'have not tried'], ['unable to deplicate', 'unable to deplicate'], ['N/A', 'N/A']]
    @select_status = [['New', 'New']]
    @select_visibility = [['Public', 'Public'], ['Internal', 'Internal']]
    @select_priority = [['None', 'None'], ['Low', 'Low'], ['Normal', 'Normal'], ['High', 'High'], ['Urgent', 'Urgent']]
    #@select_issue_origin = [['', 0], ['Missing element', 'element_manquant'], ['Vague element', 'element_imprecis'], ['Wrong element', 'element_faux'], ['Modification', 'modification'], ['Improvement', 'amelioration'], ['Environment', 'environnement']]
    #@select_lot = [['', 0], ['v1.0', 'v1.0'], ['v2.0', 'v2.0']]
    @select_entity = [['', 0], ['FuD', 'FuD'], ['PhD', 'PhD'], ['MnT', 'M&T']]
    @select_domain = [['', 0], ['EP', 'EP'], ['EV', 'EV'], ['ES', 'ES'], ['EY', 'EY'], ['EZ', 'EZ'], ['EZC', 'EZC'], ['EI', 'EI'], ['EZMC', 'EZMC'], ['EZMB', 'EZMB'], ['EC', 'EC'], ['EG', 'EG']]
    @select_origin = [['', 0], ['Airbus Feed back', 'Airbus Feed back'], ['SQLI Feed back', 'SQLI Feed back']]
    @select_dev_team = [['', 0], ['SQLI', 'SQLI'], ['EZMC', 'EZMC'], ['ICT', 'ICT']]
    @select_ci_objectives_2014 = [['', 0], ['Monitor scope management across programme', 'Monitor scope management across programme'], ['Acting on process adherence information', 'Acting on process adherence information'], ['Support E-M&T QMS setting up : Baseline all QMS components and manage them in configuration', 'Support E-M&T QMS setting up : Baseline all QMS components and manage them in configuration'], ['Support E-M&T QMS setting up : Setup Change management process involving appropriate stakeholder', 'Support E-M&T QMS setting up : Setup Change management process involving appropriate stakeholder'], ['Support E-M&T QMS setting up : Support E-M&T processes and method description and deployment', 'Support E-M&T QMS setting up : Support E-M&T processes and method description and deployment'], ['Secure convergence to GPP NG and tune its deployment in E-M&T  context : Support Agile and FastTrack deployment', 'Secure convergence to GPP NG and tune its deployment in E-M&T  context : Support Agile and FastTrack deployment'], ['Secure convergence to GPP NG and tune its deployment in E-M&T  context : Adapt Quality activities and role to Agile, and FastTrack standards', 'Secure convergence to GPP NG and tune its deployment in E-M&T  context : Adapt Quality activities and role to Agile, and FastTrack standards'], ['Secure convergence to GPP NG and tune its deployment in E-M&T  context : Deploy HLR principles (so called BD in GPP)', 'Secure convergence to GPP NG and tune its deployment in E-M&T  context : Deploy HLR principles (so called BD in GPP)'], ['Industrialise 2013 initiatives: Lessons learnt process from collection to reuse', 'Industrialise 2013 initiatives: Lessons learnt process from collection to reuse'], ['Industrialise 2013 initiatives: DW/PLM Quality activity plan setting-up, changes and monitoring', 'Industrialise 2013 initiatives: DW/PLM Quality activity plan setting-up, changes and monitoring'], ['Industrialise 2013 initiatives: Project setting optimisation and defined adjustment criteria', 'Industrialise 2013 initiatives: Project setting optimisation and defined adjustment criteria'], ['Harmonize PLM WoW and setup a PLMQAP', 'Harmonize PLM WoW and setup a PLMQAP'], ['No target objective', 'No target objective']]
    #@select_level_of_impact = [['', 0], ['Very Hight', 'Very Hight '], ['High', ' High '], ['Medium', ' Medium '], ['Low', ' Low '], ['Very low', ' Very Low']]
    @select_deployment = [['Internal', 'Internal'], ['External', 'External']]
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
        if (p.stage != "BAM" and p.stage != "" and DateTime.strptime(p.submission_date, '%d/%m/%Y %H:%M') >= filter) #DateTime.strptime('2013/09/01 16:00', '%Y/%m/%d %H:%M')))
          ci = CiProject.find_by_external_id(p.external_id)
          if not ci or ci.external_id == 0
            ci = CiProject.create(:external_id=>p.external_id)
          end
          ci.update_attributes(p.to_hash) # and it updates only the attributes that have changed !
          ci.save
        end
      }
      redirect_to '/ci_projects/all'
    rescue Exception => e
      render(:text=>e)
    end
  end

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
  end

  def edit_report
    id = params[:id]
    @project = CiProject.find(id)
  end

  def update
    p = CiProject.find(params[:id])

    old_sqli_date = p.sqli_validation_date
    old_airbus_date = p.airbus_validation_date
    old_deployment_date = p.deployment_date

    p.update_attributes(params[:project])

    validators = siglum = responsible = ""

    responsible = p.sqli_validation_responsible
    persons = Person.find(:all)
    persons.each { |person|
      if (person.name == responsible)
        siglum += person.rmt_user + "@sqli.com,"
      end
    }

    validators = siglum + APP_CONFIG['ci_date_to_validate_destination'] #-> modifier dans config.yml : "jmondy@sqli.com,ngagnaire@sqli.com,dadupont@sqli.com"

    if (old_sqli_date != p.sqli_validation_date)
      p.sqli_date_alert = 1
      date_validation_mail(validators, p)
    end
    if (old_airbus_date != p.airbus_validation_date)
      p.airbus_date_alert = 1
      date_validation_mail(validators, p)
    end
    if (old_deployment_date != p.deployment_date)
      p.deployment_date_alert = 1
      date_validation_mail(validators, p)
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
    last_external_id = 0
    projects = CiProject.find(:all).sort_by {|p| [p.external_id]}
    projects.each { |t|
      last_external_id = t.external_id
    }

    p = CiProject.new(params[:project])
    #0 car ça nous le passe en "null" ainsi Mantis incrémente tout seul l'ID.
    p.external_id = 0 #(last_external_id + 1)
    p.to_implement = 1
    p.save
    redirect_to "/ci_projects/show/"+p.id.to_s
  end

  def show
    id = params['id']
    @project = CiProject.find(id)
  end

  def mantis_export
    @export_mantis_formula = formula = formula_to_implement = ""
    @projects = CiProject.find(:all).sort_by {|p| [p.order||0, p.assigned_to||'']}
    @projects.each { |p|
      #Formule pour mettre à jour les projets existants
      if p.status!="Closed" and p.status!="Delivered" and p.status!="Rejected" and (p.to_implement == nil or p.to_implement == 0)
        formula += p.mantis_formula
        formula += ";finbug"
        formula += "\n"
      end
      #Formule pour ajouter uniquement les nouveaux projets
      if p.status!="Closed" and p.status!="Delivered" and p.status!="Rejected" and p.to_implement != nil and p.to_implement == 1
        formula_to_implement += p.mantis_formula
        formula_to_implement += ";finbug"
        formula_to_implement += "\n"
      end
    }
    @export_mantis_formula = formula
    @export_mantis_formula_to_implement = formula_to_implement
  end

  def mantis_implemented
    @projects = CiProject.find(:all).sort_by {|p| [p.order||0, p.assigned_to||'']}
    @projects.each { |p|
      if p.to_implement == 1
        p.to_implement = 0
        CiProject.delete(p)
      end
      p.save
    }
    redirect_to "/ci_projects/all"
  end

  def date_validation_mail(validators, project)
      Mailer::deliver_ci_date_change(validators, project)
  end

  def dashboard
    @ci_projects = CiProject.find(:all, :conditions=>"visibility = 'Public' and status = 'Assigned'").sort_by {|p| [p.order]}
  end

end
