require 'lib/csv_ci'
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
    @select_type = [['Anomaly', 20],['Evolution', 50]]
    @select_stage = [['', 0], ['Continuous Improvement', 32182], ['Test_CI', 33082]]
    @select_category = [['', 0], ['Autres', 21360], ['Bundle', 21361], ['Methodo Airbus (GPP, LBIP ...)', 21362], ['Methodo Airbus (GPP, LBIP...)', 21363], ['Project', 21364]]
    @select_severity = [['', 0], ['text', 30], ['tweak', 40], ['minor', 50], ['major', 60], ['block', 80]]
    @select_reproductibility = [['', 0], ['alaways', 10], ['sometimes', 30], ['random', 50], ['have not tried', 70], ['unable to deplicate', 90], ['N/A', 100]]
    @select_status = [['', 0], ['New', 10], ['Analyse', 12], ['Qualification', 17], ['Comment', 20], ['Accepted', 30], ['Assigned', 50], ['Realised', 80], ['Verified', 82], ['Validated', 85], ['Delivered', 87], ['Reopened', 88], ['Closed', 90], ['Rejected', 95]]
    @select_reporter_and_responsible = [['', 0], ['acario', 10000720], ['agoupil', 999843], ['bmonteils', 9999622], ['btisseur', 46], ['ccaron', 10000292], ['capottier', 10000560], ['cpages', 9999919], ['cdebortoli', 9999245], ['dadupont', 4437], ['fplisson', 9999515], ['jmondy', 7772], ['lbalansac', 100000222], ['mbuscail', 9999327], ['mmaglionepiromallo', 7728], ['mantoine', 7793], ['mblatche', 9999516], ['mbekkouch', 3652], ['nrigaud', 10000958], ['ngagnaire', 10000260], ['nmenvielle', 10000710], ['ocabrera', 10001140], ['pdestefani', 10000559], ['pescande', 9999311], ['pcauquil', 7323], ['rbaillard', 10000709], ['rallin', 7363], ['swezel', 10001620], ['saury', 10000239], ['stessier', 7330], ['vlaffont', 7155], ['zallou', 10000629]]
    @select_visibility = [['', 0], ['Public', 10], ['Internal', 50]]
    @select_priority = [['', 0], ['None', 10], ['Low', 20], ['Normal', 30], ['High', 40], ['Urgent', 50]]
    @select_detection_version = [['', 0], ['v1.0', 13330], ['v2.0', 13382]]
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
        if (p.stage != "BAM" and p.stage != "")
          ci = CiProject.find_by_external_id(p.external_id)
          ci.to_implement = 0 if ci.to_implement == 1
          ci = CiProject.create(:external_id=>p.exterbal_id) if not ci
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
    report = CsvCiReport.new(path)
    begin
      report.parse
      # transform the Report into a CiProject
      report.projects.each { |p|
        # get the id if it exist
        # ici il faut vérifier le format de l'external_id pour voir si c'est un CI, une Expertise ou un Coaching.
        if (p.stage != "BAM" and p.stage != "" and p.external_id != "")
          ci = CiProject.find_by_external_id(p.external_id)
          ci.update_attributes(p.to_hash) # and it updates only the attributes that have changed !
          ci.save
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
    p = CiProject.new(params[:project])
    p.to_implement = 1
    p.save
    redirect_to "/ci_projects/show/"+p.id.to_s
  end

  def show
    id = params['id']
    @project = CiProject.find(id)
  end

  def mantis_export
    @export_mantis_formula = formula = ""
    @projects = CiProject.find(:all).sort_by {|p| [p.order||0, p.assigned_to||'']}
    @projects.each { |p|
      if p.status!="Closed" and p.status!="Delivered" and p.status!="Rejected"
        formula += p.mantis_formula
        formula += ";finbug"
      end
    }
    @export_mantis_formula = formula

    #formule pour test, à supprimer
    @export_mantis_formula_test = formula_test = ""
    #@projects_test = CiProject.find(:all, :conditions=>"external_id='380' or external_id='389' or external_id='395' or external_id='439'").sort_by {|p| [p.order||0, p.assigned_to||'']}
    @projects_test = CiProject.find(:all, :conditions=>"external_id='587'").sort_by {|p| [p.order||0, p.assigned_to||'']}
    @projects_test.each { |p|
        formula_test += p.mantis_formula
        formula_test += ";finbug"
    }
    @export_mantis_formula_test = formula_test
  end

  def date_validation_mail(validators, project)
      Mailer::deliver_ci_date_change(validators, project)
  end

end
