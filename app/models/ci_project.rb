    class CiProject < ActiveRecord::Base

        def mantis_formula	
    	external_id_temp = "null"
    	if self.external_id.to_s != "" and self.external_id.to_s != nil
    	   external_id_temp = self.external_id.to_s
    	end
    	
    	formula = ""
    	formula += external_id_temp #ID Externe
    	formula += list_type(self.type) #Type
    	formula += list_stage(self.stage) #Etape
    	formula += list_category(self.category) #Catégorie
    	formula += ";null" #Exigences
    	formula += list_severity(self.severity) #Sévérité
    	formula += list_reproducibility(self.reproducibility) #Reproductibilité
    	formula += format(self.summary) #Intitulé
    	formula += format(self.description) #Description
    	formula += list_status(self.status) #Etat
    	formula += format(self.submission_date) #Soumis le
    	formula += list_reporter_and_responsible(self.reporter) #Rapporteur
    	formula += list_visibility(self.visibility) #Public/Interne
    	formula += list_reporter_and_responsible(self.assigned_to) #Responsable
    	formula += list_priority(self.priority) #Priorité
    	formula += ";null" #Version de détection
    	formula += ";null" #Version de prise en compte
    	formula += ";null" #Charge de résolution (en heures)
    	formula += ";null" #Etapes pour reproduire
    	formula += format(self.additional_information) #Informations complémentaires
    	formula += ";null" #Cause de la demande
    	formula += ";null" #Phase de détection
    	formula += ";null" #Phase d'injection
    	formula += ";null" #Test réel de détection
    	formula += ";null" #Test théorique de détection
    	formula += format(self.impact) #Impact (en j/h)
    	formula += format(self.impact_time) #Impact en délai (en j)
    	formula += list_typology_of_change(self.typology_of_change) #Typologie du changement
    	formula += format(self.deliverables_updated) #Livrables mis à jour
    	formula += format(self.iteration) #Itération
    	formula += format(self.lot) #Lot
    	formula += format(self.entity) #Entité
    	formula += format(self.team) #Equipe
    	formula += format(self.domain) #Domaine
    	formula += format(self.backlog_request_id) #Num Req Backlog
    	formula += format(self.origin) #Origin
    	formula += ";null" #Output Type
    	formula += ";null" #Deliverables list
    	formula += ";null" #Dev Team
    	formula += ";null" #Deployment
    	formula += format(self.airbus_responsible) #Airbus Responsible
    	formula += invert_date(self.airbus_validation_date) #Airbus validation date
    	formula += invert_date(self.airbus_validation_date_objective) #Airbus validation date objective
    	formula += invert_date(self.airbus_validation_date_review) #Airbus Validation Date Review
    	formula += format(self.ci_objectives_2010_2011) #CI Objective 2010/2011
    	formula += format(self.ci_objectives_2012) #CI Objective 2012
    	formula += format(self.ci_objectives_2013) #CI Objectives 2013
    	formula += format(self.deliverable_folder) #Deliverable Folder
    	formula += invert_date(self.deployment_date) #Deployment date
    	formula += invert_date(self.deployment_date_objective) #Deployment date objective
    	formula += invert_date(self.specification_date) #Specification date
    	formula += invert_date(self.kick_off_date) #Kick-Off Date
    	formula += invert_date(self.launching_date_ddmmyyyy) #Launching date (dd/mm/yyyy)
    	formula += invert_date(self.sqli_validation_date) #SQLI Validation date
    	formula += invert_date(self.sqli_validation_date_objective) #SQLI Validation date objective
    	formula += invert_date(self.specification_date_objective) #Specification date Objective
    	formula += format(self.sqli_validation_responsible) #SQLI validation Responsible
    	formula += format(self.ci_objectives_2014) #CI Objectives 2014
    	formula += invert_date(self.kick_off_date) #Airbus Kick-Off Date
    	formula += format(self.airbus_responsible) #Airbus validation responsible
    	formula += format(self.linked_req) #Linked Req
    	formula += format(self.quick_fix) #Quick Fix
    	formula += format(self.level_of_impact) #Level of Impact
    	formula += format(self.impacted_mnt_process) #Impacted M&T process
    	formula += format(self.path_backlog) #Path backlog
    	formula += format(self.svn_delivery_folder) #Path SVN
    	formula += format(self.path_sfs_airbus) #Path SFS Airbus
    	formula += format(self.item_type) #Item Type
    	formula += invert_date(self.verification_date_objective) #Verification Date Objective
    	formula += invert_date(self.verification_date) #Verification Date
    	formula += format(self.request_origin) #Request Origin
    	
    	return formula
	end

    def invert_date(date)
        dateinverted = ";"+date.to_s

        #dateconvert = date.day+"/"+date.month+"/"+date.year
        #dateconvert = format(dateconvert)
        #return dateconvert
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
        var = "32182"
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

    def list_reproducibility(var)
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
        when "Qqualification"
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

    def list_typology_of_change(var)
        case var
        when "New requirement"
            puts var = "new_requirement"
        when "Requirement updatable"
            puts var = "modif_requirement"
        when "Micro-change"
            puts var = "micro_change"
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
    	if self.sqli_validation_date_review and (self.status=="Accepted" or self.status=="Assigned") and self.sqli_validation_date_review <= Date.today()
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
    	return nil if !self.sqli_validation_date_objective
    	return self.sqli_validation_date_review - self.sqli_validation_date_objective
	end
	
	def sqli_delay_new
    	return nil if !self.sqli_validation_date_objective
    	return self.sqli_validation_date - self.sqli_validation_date_objective
	end
	
	def airbus_delay
    	return nil if !self.airbus_validation_date_objective
    	return self.airbus_validation_date_review - self.airbus_validation_date_objective
	end
	
	def airbus_delay_new
    	return nil if !self.airbus_validation_date_objective
    	return self.airbus_validation_date - self.airbus_validation_date_objective
	end
	
	def deployment_delay
    	return nil if !self.deployment_date_objective
    	return self.deployment_date_review - self.deployment_date_objective
	end
	
	def deployment_delay_new
    	return nil if !self.deployment_date_objective
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