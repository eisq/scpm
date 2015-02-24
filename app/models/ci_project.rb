    class CiProject < ActiveRecord::Base

        def mantis_formula

    	external_id_temp = "null"
    	if self.external_id.to_s != nil and self.external_id.to_s != "" and self.external_id != 0
            if self.extract_bam_external_id == 0 and self.to_implement == 1
                external_id_temp = self.external_id
            else
                external_id_temp = self.extract_bam_external_id.to_s
            end
    	end

        formula = ""
        if external_id_temp != "null" and external_id_temp != "0"
            formula += external_id_temp #ID Externe
            formula += list_type(self.ci_type)
            formula += list_stage(self.stage)
            formula += list_category(self.category)
            formula += ";null" #Requirements
            formula += list_severity(self.severity)
            formula += list_reproductibility(self.reproductibility)
            formula += format(self.summary)
            formula += format(self.description)
            formula += list_status(status)
            formula += format(self.submission_date)
            formula += list_reporter_and_responsible(self.reporter)
            #formula += format(self.last_update)
            #formula += format(self.last_update_person)
            formula += list_visibility(self.visibility)
            formula += list_reporter_and_responsible(self.assigned_to)
            formula += list_priority(self.priority)
            formula += list_detection_version(self.detection_version)
            formula += list_fixed_in_version(self.fixed_in_version)
            #formula += format(self.status_precisions)
            formula += ";null" #format(self.resolution_charge)
            #formula += format(self.duplicated_id)
            formula += ";null" #format(self.stages_to_reproduce)
            formula += format(self.additional_informations)
            #formula += invert_date(self.taking_into_account_date)
            #formula += invert_date(self.realisation_date)
            #formula += format(self.realisation_author)
            #formula += invert_date(self.delivery_date)
            #formula += invert_date(self.reopening_date)
            formula += format(self.issue_origin)
            formula += ";null" #format(self.detection_phase)
            formula += ";null" #format(self.injection_phase)
            formula += ";null" #format(self.real_test_of_detection)
            formula += ";null" #format(self.theoretical_test_of_detection)
            formula += ";null" # Impact (in m/d)
            formula += ";null" # Impact in delay (in days)
            formula += ";null" # Change type
            formula += ";null" # Updated deliverables
            formula += format(self.iteration)
            formula += format(self.lot)
            formula += format(self.entity)
            formula += ";null" #format(self.team)
            formula += format(self.domain)
            formula += format(self.num_req_backlog)
            formula += format(self.origin)
            formula += ";null" #format(self.output_type)
            formula += format(self.deliverables_list)
            formula += format(self.dev_team)
            formula += invert_date(self.deployment)
            formula += format(self.airbus_responsible)
            formula += invert_date(self.airbus_validation_date)
            formula += invert_date(self.airbus_validation_date_objective)
            formula += invert_date(self.airbus_validation_date_review)
            formula += format(self.ci_objective_20102011)
            formula += format(self.ci_objective_2012)
            formula += format(self.ci_objectives_2013)
            formula += format(self.deliverable_folder)
            formula += invert_date(self.deployment_date)
            formula += invert_date(self.deployment_date_objective)
            formula += invert_date(self.specification_date)
            formula += invert_date(self.kick_off_date)
            formula += invert_date(self.launching_date_ddmmyyyy)
            formula += invert_date(self.sqli_validation_date)
            formula += invert_date(self.sqli_validation_date_objective)
            formula += invert_date(self.specification_date_objective)
            formula += format(self.sqli_validation_responsible)
            formula += format(self.ci_objectives_2014)
            formula += ";null" # Airbus kick-off date
            formula += ";null" # Airbus validation responsible
            formula += format(self.linked_req)
            formula += format(self.quick_fix)
            formula += format(self.level_of_impact)
            formula += format(self.impacted_mnt_process)
            formula += format(self.path_backlog)
            formula += format(self.path_svn)
            formula += format(self.path_sfs_airbus)
            formula += format(self.item_type)
            formula += invert_date(self.verification_date_objective)
            formula += invert_date(self.verification_date)
            formula += format(self.request_origin)
            formula += format(self.ci_objectives_2015)
            #formula += format(self.issue_history)
            formula += ";finbug"
            formula += "\n"
        end
    	return formula
	end

    def extract_bam_external_id
        bam_external_id = 0
        if self.external_id.length > 7
            temp, bam_external_id_temp = self.external_id.to_s.split(" [")
            bam_external_id, temp = bam_external_id_temp.to_s.split("]")
        end
        return bam_external_id.to_i
    end

    def self.extract_bam_external_id(external_id_local)
        bam_external_id = 0
        if external_id_local.length > 7
            temp, bam_external_id_temp = external_id_local.to_s.split(" [")
            bam_external_id, temp = bam_external_id_temp.to_s.split("]")
        end
        return bam_external_id.to_i
    end

    def extract_mantis_external_id
        mantis_external_id = 0
        if self.external_id.length > 7
            mantis_external_id, temp = self.external_id.to_s.split(" [")
        end
        return mantis_external_id.to_i
    end

    def invert_date(date)
        if date == "" or date == nil
            dateinverted = "null"
        else
            year,month,day = date.to_s.split("-")
            if year.to_i < 100
                year = "20"+year.to_s
            end
            dateinverted = day+"/"+month+"/"+year
        end

        dateinverted = format(dateinverted)
        return dateinverted
    end

    def list_type(var)
        case var
        when "Anomaly"
            puts var = "10"
        when "Evolution"
            puts var = "50"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_stage(var)
        case var
        when "Continuous Improvement"
            puts var = "32182"
        when "Test_CI"
            puts var = "33082"
        else
            puts var = "0"
        end
        var = format(var)
        return var
    end

    def list_category(var)
        case var
            when "Autres"
                puts var = "21360"
            when "Bundle"
                puts var = "21361"
            when "Methodo Airbus (GPP, LBIP ...)"
                puts var = "21362"
            when "Methodo Airbus (GPP, LBIP...)"
                puts var = "21363"
            when "Project"
                puts var = "21364"
            else
                puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_severity(var)
        case var
        when "text"
            puts var = "30"
        when "tweak"
            puts var = "40"
        when "minor"
            puts var = "50"
        when "major"
            puts var = "60"
        when "block"
            puts var = "80"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_reproductibility(var)
        case var
        when "always"
            puts var = "10"
        when "sometimes"
            puts var = "30"
        when "random"
            puts var = "50"
        when "have not tried"
            puts var = "70"
        when "unable to duplicate"
            puts var = "90"
        when "N/A"
            puts var = "100"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_status(var)
        case var
        when "New"
            puts var = "10"
        when "Analyse"
            puts var = "12"
        when "Qualification"
            puts var = "17"
        when "Comment"
            puts var = "20"
        when "Accepted"
            puts var = "30"
        when "Assigned"
            puts var = "50"
        when "Realised"
            puts var = "80"
        when "Verified"
            puts var = "82"
        when "Validated"
            puts var = "85"
        when "Delivered"
            puts var = "87"
        when "Reopened"
            puts var = "88"
        when "Closed"
            puts var = "90"
        when "Rejected"
            puts var = "95"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_reporter_and_responsible(var)
        case var
        when "acario"
            puts var = "10000720"
        when "agoupil"
            puts var = "999843"
        when "bmonteils"
            puts var = "9999622"
        when "btisseur"
            puts var = "46"
        when "ccaron"
            puts var = "10000292"
        when "capottier"
            puts var = "10000560"
        when "cpages"
            puts var = "9999919"
        when "cdebortoli"
            puts var = "9999245"
        when "dadupont"
            puts var = "4437"
        when "fplisson"
            puts var = "9999515"
        when "jmondy"
            puts var = "7772"
        when "lbalansac"
            puts var = "100000222"
        when "mbuscail"
            puts var = "9999327"
        when "mmaglionepiromallo"
            puts var = "7728"
        when "mantoine"
            puts var = "7793"
        when "mblatche"
            puts var = "9999516"
        when "mbekkouch"
            puts var = "3652"
        when "nrigaud"
            puts var = "10000958"
        when "ngagnaire"
            puts var = "10000260"
        when "nmenvielle"
            puts var = "10000710"
        when "ocabrera"
            puts var = "10001140"
        when "pdestefani"
            puts var = "10000559"
        when "pescande"
            puts var = "9999311"
        when "pcauquil"
            puts var = "7323"
        when "rbaillard"
            puts var = "10000709"
        when "rallin"
            puts var = "7363"
        when "swezel"
            puts var = "10001620"
        when "saury"
            puts var = "10000239"
        when "stessier"
            puts var = "7330"
        when "vlaffont"
            puts var = "7155"
        when "zallou"
            puts var = "10000629"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_visibility(var)
        case var
        when "Public"
            puts var = "10"
        when "Internal"
            puts var = "50"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_priority(var)
        case var
        when "None"
            puts var = "10"
        when "Low"
            puts var = "20"
        when "Normal"
            puts var = "30"
        when "High"
            puts var = "40"
        when "Urgent"
            puts var = "50"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_detection_version(var)
        case var
        when "v1.0"
            puts var = "13330"
        when " v1.0"
            puts var = "13330"
        when "v2.0"
            puts var = "13382"
        when " v2.0"
            puts var = "13382"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

    def list_fixed_in_version(var)
        case var
        when "v1.0"
            puts var = "13330"
        when "v2.0"
            puts var = "13382"
        else
            puts var = "null"
        end
        var = format(var)
        return var
    end

	def format(variable) #formate les variables pour les entrer dans la formule d'export Mantis.
    	var = variable.to_s
    	if var == "" or var == nil or var == " "
    	   var = "null"
    	end
    	   var = ";" + var
           var = sanitize_accents(var)
    	return var
	end

    def sanitize_formula(value)
        value.gsub!(130.chr, "e") # eacute
        value.gsub!(133.chr, "a") # a grave
        value.gsub!(135.chr, "c") # c cedille
        value.gsub!(138.chr, "e") # e grave
        value.gsub!(140.chr, "i") # i flex
        value.gsub!(147.chr, "o") # o flex
        value.gsub!(156.chr, "oe") # oe
        value.gsub!(167.chr, "o") # °
        return value
    end
	
	def css_class
    	if self.status == "New"
    	return "ci_project new"
    	elsif self.status == "Accepted"
    	return "ci_project acknowledged"
    	elsif self.status == "Assigned"
    	return "ci_project assigned"
    	elsif self.status == "Closed"
    	return "ci_project action_closed"
    	elsif self.status == "Comment"
    	return "ci_project feedback"
    	elsif self.status == "Delivered"
    	return "ci_project performed"
    	elsif self.status == "Rejected"
    	return "ci_project cancelled"
    	elsif self.status == "Verified"
    	return "ci_project to_be_validated"
    	elsif self.status == "Validated"
    	return "ci_project validated"
    	end
    	""
	end
	
	def is_late_css
    	if self.sqli_validation_date and (self.status=="Accepted" or self.status=="Assigned") and self.sqli_validation_date <= Date.today()
    		return "ci_late_report"
    	elsif self.airbus_validation_date_review and self.status=="Verified" and self.airbus_validation_date_review <= Date.today()
    		return "ci_late_report"
    	end
    	""	
	end
	
	def self.late_css(date)
    	return "" if !date
    	return "ci_late" if date <= Date.today()
	""	
	end
	
	def self.is_late(date)
    	return false if !date
    	return true if date <= Date.today()
    	return false
	end
	
	def sqli_delay
    	return nil if !self.sqli_validation_date_objective or !self.sqli_validation_date
    	return self.sqli_validation_date - self.sqli_validation_date_objective
	end
	
	def sqli_delay_new
    	return nil if !self.sqli_validation_date_objective or !self.sqli_validation_date
    	return self.sqli_validation_date - self.sqli_validation_date_objective
	end
	
	def airbus_delay
    	return nil if !self.airbus_validation_date_objective or !self.airbus_validation_date
    	return self.airbus_validation_date - self.airbus_validation_date_objective
	end
	
	def airbus_delay_new
    	return nil if !self.airbus_validation_date_objective or !self.airbus_validation_date
    	return self.airbus_validation_date - self.airbus_validation_date_objective
	end
	
	def deployment_delay
    	return nil if !self.deployment_date_objective or !self.deployment_date
    	return self.deployment_date - self.deployment_date_objective
	end
	
	def deployment_delay_new
    	return nil if !self.deployment_date_objective or !self.deployment_date
    	return self.deployment_date - self.deployment_date_objective
	end
	
	def interprate_delay(delay)
    	return delay.to_s if delay < 30
    	return "1 month+ delay" if (delay >= 30 and delay < 60)
    	return "2 month+ delay" if (delay >= 60 and delay < 90)
    	return "3 month+ delay" if delay >= 90
	end
	
	def short_stage
    	return case self.stage
    	when 'Continuous Improvement'
    	"CI"
    	when 'BAM'
    	"BAM"
    	when 'Request Management Tool'
    	"RMT"
    	end
	end
	
	def order
    	return case self.status
    	when "New"
    	10
    	when "Accepted"
    	20
    	when "Assigned"
    	30
    	when "Closed"
    	100
    	when "Comment"
    	40
    	when "Verified"
    	50
    	when "Validated"
    	80
    	when "Delivered"
    	90
    	when "Rejected"
    	110
    	else	
    	0
    	end
	end

    def self.get_ci_type
        ci_type = [['Anomaly', 'Anomaly'], ['Evolution', 'Evolution']]
        return ci_type
    end

    def self.get_stage
        stage = [['Continuous Improvement', 'Continuous Improvement']]
        return stage
    end

    def self.get_category
        category = [['Autres', 'Autres'], ['Bundle', 'Bundle'], ['Methodo Airbus (GPP, LBIP ...)', 'Methodo Airbus (GPP, LBIP ...)'], ['Methodo Airbus (GPP, LBIP...)', 'Methodo Airbus (GPP, LBIP...)'], ['Project', 'Project']]
        return category
    end

    def self.get_severity
        severity = [['minor', 'minor'], ['major', 'major'], ['block', 'block'], ['text', 'text'], ['tweak', 'tweak']]
        return severity
    end

    def self.get_reproductibility
        reproductibility = [['always', 'always'], ['sometimes', 'sometimes'], ['random', 'random'], ['have not tried', 'have not tried'], ['unable to deplicate', 'unable to deplicate'], ['N/A', 'N/A']]
        return reproductibility
    end

    def self.get_status
        status = [['New', 'New']]
        return status
    end

    def self.get_visibility
        visibility = [['Public', 'Public'], ['Internal', 'Internal']]
        return visibility
    end

    def self.get_priority
        priority = [['None', 'None'], ['Low', 'Low'], ['Normal', 'Normal'], ['High', 'High'], ['Urgent', 'Urgent']]
        return priority
    end

    def self.issue_origin
        issue_origin = [['', 0], ['Missing element', 'element_manquant'], ['Vague element', 'element_imprecis'], ['Wrong element', 'element_faux'], ['Modification', 'modification'], ['Improvement', 'amelioration'], ['Environment', 'environnement']]
        return issue_origin
    end

    def self.get_lot
        lot = [['', 0], ['v1.0', 'v1.0'], ['v2.0', 'v2.0']]
        return lot
    end

    def self.get_entity
        entity = [['', 0], ['FuD', 'FuD'], ['PhD', 'PhD'], ['MnT', 'M&T']]
        return entity
    end

    def self.get_domain
        domain = [['', 0], ['EP', 'EP'], ['EV', 'EV'], ['ES', 'ES'], ['EY', 'EY'], ['EZ', 'EZ'], ['EZC', 'EZC'], ['EI', 'EI'], ['EZMC', 'EZMC'], ['EZMB', 'EZMB'], ['EC', 'EC'], ['EG', 'EG']]
        return domain
    end

    def self.get_origin
        origin = [['', 0], ['Airbus Feed back', 'Airbus Feed back'], ['SQLI Feed back', 'SQLI Feed back']]
        return origin
    end

    def self.get_dev_team
        dev_team = [['', 0], ['SQLI', 'SQLI'], ['EZMC', 'EZMC'], ['ICT', 'ICT']]
        return dev_team
    end

    def self.get_ci_objectives_2014
        ci_objectives_2014 = [['', 0], ['Monitor scope management across programme', 'Monitor scope management across programme'], ['Acting on process adherence information', 'Acting on process adherence information'], ['Support E-M&T QMS setting up : Baseline all QMS components and manage them in configuration', 'Support E-M&T QMS setting up : Baseline all QMS components and manage them in configuration'], ['Support E-M&T QMS setting up : Setup Change management process involving appropriate stakeholder', 'Support E-M&T QMS setting up : Setup Change management process involving appropriate stakeholder'], ['Support E-M&T QMS setting up : Support E-M&T processes and method description and deployment', 'Support E-M&T QMS setting up : Support E-M&T processes and method description and deployment'], ['Secure convergence to GPP NG and tune its deployment in E-M&T  context : Support Agile and FastTrack deployment', 'Secure convergence to GPP NG and tune its deployment in E-M&T  context : Support Agile and FastTrack deployment'], ['Secure convergence to GPP NG and tune its deployment in E-M&T  context : Adapt Quality activities and role to Agile, and FastTrack standards', 'Secure convergence to GPP NG and tune its deployment in E-M&T  context : Adapt Quality activities and role to Agile, and FastTrack standards'], ['Secure convergence to GPP NG and tune its deployment in E-M&T  context : Deploy HLR principles (so called BD in GPP)', 'Secure convergence to GPP NG and tune its deployment in E-M&T  context : Deploy HLR principles (so called BD in GPP)'], ['Industrialise 2013 initiatives: Lessons learnt process from collection to reuse', 'Industrialise 2013 initiatives: Lessons learnt process from collection to reuse'], ['Industrialise 2013 initiatives: DW/PLM Quality activity plan setting-up, changes and monitoring', 'Industrialise 2013 initiatives: DW/PLM Quality activity plan setting-up, changes and monitoring'], ['Industrialise 2013 initiatives: Project setting optimisation and defined adjustment criteria', 'Industrialise 2013 initiatives: Project setting optimisation and defined adjustment criteria'], ['Harmonize PLM WoW and setup a PLMQAP', 'Harmonize PLM WoW and setup a PLMQAP'], ['No target objective', 'No target objective']]
        return ci_objectives_2014
    end

    def self.get_level_of_impact
        level_of_impact = [['', 0], ['Very Hight', 'Very Hight '], ['High', ' High '], ['Medium', ' Medium '], ['Low', ' Low '], ['Very low', ' Very Low']]
        return level_of_impact
    end

    def self.get_deployment
        deployment = [['Internal', 'Internal'], ['External', 'External']]
        return deployment
    end

    def self.get_ci_objectives_2015
        ci_objectives_2015 = [['', 0], ['Support E-M&T referential publication and maintenance based on E-M&T processes (Plan, Build, Run and Monitor and Control) and contribute to optimize/rationalize E-M&T referential.', 'Support E-M&T referential publication and maintenance based on E-M&T processes (Plan, Build, Run and Monitor and Control) and contribute to optimize/rationalize E-M&T referential.'], ['Secure EIS of the new quality plan process and associated templates for Suite, and Projects integrating impact on all E-M&T quality activities.', 'Secure EIS of the new quality plan process and associated templates for Suite, and Projects integrating impact on all E-M&T quality activities.'], ['Monitor compliance of the project to their plans and share discrepancies with the Project steering committee.', 'Monitor compliance of the project to their plans and share discrepancies with the Project steering committee.'], ['Capitalize and act on process adherence information.', 'Capitalize and act on process adherence information.'], ['Adapt and deploy a process of lessons learnt based on the use of collaborative tools.', 'Adapt and deploy a process of lessons learnt based on the use of collaborative tools.'], ['Support the deployment of Documentation Centre solution.', 'Support the deployment of Documentation Centre solution.'], ['Secure continuity of service for 2016', 'Secure continuity of service for 2016'], ['No target objective', 'No target objective']]
        return ci_objectives_2015
    end

    def self.get_justifications
        justifications = Array.new
        justifications << "No justification."
        justifications << "On hold (other CI dependency)."
        justifications << "Consideration of validation returns (wrong scope)."
        justifications << "Consideration of validation returns (not complete)."
        justifications << "Unavailability of internal CI participant (noticed from the kick-off as participant)."
        justifications << "Unavailability of internal CI participant (participation not planned at kick-off)"
        justifications << "Work under estimated."
        justifications << "Waiting for internal validation (verification)."
        justifications << "Waiting for external validation (validation)."
        justifications << "Waiting for Airbus deliverable or information."
        justifications << "Other (please explain the reason in the reporting)."

        return justifications
    end
	
	def sanitized_status
	   sanitize(self.css_class)
	end
	
	private
	
	def sanitize(name)
    	name = name.downcase
    	name.gsub!("ci_project ","")
    	name.gsub!("/","")
    	name.gsub!(" ","_")
    	name.gsub!(" ","_")
    	name.gsub!("-","_")
    	name
	end

    def sanitize_accents(value)
    value.gsub!(130.chr, "e") # eacute
    value.gsub!(133.chr, "a") # a grave
    value.gsub!(135.chr, "c") # c cedille
    value.gsub!(138.chr, "e") # e grave
    value.gsub!(140.chr, "i") # i flex
    value.gsub!(147.chr, "o") # o flex
    value.gsub!(156.chr, "oe") # oe
    value.gsub!(167.chr, "o") # °
    value.gsub!(150.chr, "u") # û
    value.gsub!(136.chr, "e") # ê
    #value.gsub!(245.chr, "ch") # §
    return value
  end
end