    class CiProject < ActiveRecord::Base

        def mantis_formula	
    	external_id_temp = "null"
    	if self.external_id.to_s != "" and self.external_id.to_s != nil
    	   external_id_temp = self.external_id.to_s
    	end
    	
    	formula = ""
    	formula += external_id_temp #ID Externe
    	formula += list_type(self.type) #Type
    	formula += format(self.stage) #Etape
    	formula += format(self.category) #Catégorie
    	formula += ";null" #Exigences
    	formula += format(self.severity) #Sévérité
    	formula += format(self.reproducibility) #Reproductibilité
    	formula += format(self.summary) #Intitulé
    	formula += self.description #Description
    	formula += format(self.status) #Etat
    	formula += format(self.submission_date) #Soumis le
    	formula += format(self.reporter) #Rapporteur
    	formula += format(self.visibility) #Public/Interne
    	formula += format(self.assigned_to) #Responsable
    	formula += format(self.priority) #Priorité
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
    	formula += format(self.typology_of_change) #Typologie du changement
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
    	formula += format(self.airbus_validation_date) #Airbus validation date
    	formula += format(self.airbus_validation_date_objective) #Airbus validation date objective
    	formula += format(self.airbus_validation_date_review) #Airbus Validation Date Review
    	formula += format(self.ci_objectives_2010_2011) #CI Objective 2010/2011
    	formula += format(self.ci_objectives_2012) #CI Objective 2012
    	formula += format(self.ci_objectives_2013) #CI Objectives 2013
    	formula += format(self.deliverable_folder) #Deliverable Folder
    	formula += format(self.deployment_date) #Deployment date
    	formula += format(self.deployment_date_objective) #Deployment date objective
    	formula += format(self.specification_date) #Specification date
    	formula += format(self.kick_off_date) #Kick-Off Date
    	formula += format(self.launching_date_ddmmyyyy) #Launching date (dd/mm/yyyy)
    	formula += format(self.sqli_validation_date) #SQLI Validation date
    	formula += format(self.sqli_validation_date_objective) #SQLI Validation date objective
    	formula += format(self.specification_date_objective) #Specification date Objective
    	formula += format(self.sqli_validation_responsible) #SQLI validation Responsible
    	formula += format(self.ci_objectives_2014) #CI Objectives 2014
    	formula += format(self.kick_off_date) #Airbus Kick-Off Date
    	formula += format(self.airbus_responsible) #Airbus validation responsible
    	formula += format(self.linked_req) #Linked Req
    	formula += format(self.quick_fix) #Quick Fix
    	formula += format(self.level_of_impact) #Level of Impact
    	formula += format(self.impacted_mnt_process) #Impacted M&T process
    	formula += format(self.path_backlog) #Path backlog
    	formula += format(self.svn_delivery_folder) #Path SVN
    	formula += format(self.path_sfs_airbus) #Path SFS Airbus
    	formula += format(self.item_type) #Item Type
    	formula += format(self.verification_date_objective) #Verification Date Objective
    	formula += format(self.verification_date) #Verification Date
    	formula += format(self.request_origin) #Request Origin
    	
    	return formula
	end

    def invert_date(date)


        return date
    end

    def list_type(var)
        case var
        when var == "Anomaly"
            puts var = "10"
        when var == "Evolution"
            puts var = "50"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_stage
        var = "32182"
        var = format(var)
        return var
    end

    def list_category
        case var
        when var == "Autres"
            puts var = "21360"
        when var == "Bundle"
            puts var = "21361"
        when var == "Methodo Airbus (GPP, LBIP ...)"
            puts var = "21362"
        when var == "Methodo Airbus (GPP, LBIP...)"
            puts var = "21363"
        when var == "Project"
            puts var = "21364"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_severity
        case var
        when var == "text"
            puts var = "30"
        when var == "tweak"
            puts var = "40"
        when var == "minor"
            puts var = "50"
        when var == "major"
            puts var = "60"
        when var == "block"
            puts var = "80"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_reproducibility
        case var
        when var == "always"
            puts var = "10"
        when var == "sometimes"
            puts var = "30"
        when var == "random"
            puts var = "50"
        when var == "have not tried"
            puts var = "70"
        when var == "unable to duplicate"
            puts var = "90"
        when var == "N/A"
            puts var = "100"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_status
        case var
        when var == "New"
            puts var = "10"
        when var == "Analyse"
            puts var = "12"
        when var == "Qqualification"
            puts var = "17"
        when var == "Comment"
            puts var = "20"
        when var == "Accepted"
            puts var = "30"
        when var == "Assigned"
            puts var = "50"
        when var == "Realised"
            puts var = "80"
        when var == "Verified"
            puts var = "82"
        when var == "Validated"
            puts var = "85"
        when var == "Delivered"
            puts var = "87"
        when var == "Reopened"
            puts var = "88"
        when var == "Closed"
            puts var = "90"
        when var == "Rejected"
            puts var = "95"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_reporter_and_responsible
        case var
        when var == "acario"
            puts var = "10000720"
        when var == "agoupil"
            puts var = "999843"
        when var == "bmonteils"
            puts var = "9999622"
        when var == "btisseur"
            puts var = "46"
        when var == "ccaron"
            puts var = "10000292"
        when var == "capottier"
            puts var = "10000560"
        when var == "cpages"
            puts var = "9999919"
        when var == "cdebortoli"
            puts var = "9999245"
        when var == "dadupont"
            puts var = "4437"
        when var == "fplisson"
            puts var = "9999515"
        when var == "jmondy"
            puts var = "7772"
        when var == "lbalansac"
            puts var = "100000222"
        when var == "mbuscail"
            puts var = "9999327"
        when var == "mmaglionepiromallo"
            puts var = "7728"
        when var == "mantoine"
            puts var = "7793"
        when var == "mblatche"
            puts var = "9999516"
        when var == "mbekkouch"
            puts var = "3652"
        when var == "nrigaud"
            puts var = "10000958"
        when var == "ngagnaire"
            puts var = "10000260"
        when var == "nmenvielle"
            puts var = "10000710"
        when var == "ocabrera"
            puts var = "10001140"
        when var == "pdestefani"
            puts var = "10000559"
        when var == "pescande"
            puts var = "9999311"
        when var == "pcauquil"
            puts var = "7323"
        when var == "rbaillard"
            puts var = "10000709"
        when var == "rallin"
            puts var = "7363"
        when var == "swezel"
            puts var = "10001620"
        when var == "saury"
            puts var = "10000239"
        when var == "stessier"
            puts var = "7330"
        when var == "vlaffont"
            puts var = "7155"
        when var == "zallou"
            puts var = "10000629"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_visibility
        case var
        when var == "Public"
            puts var = "10"
        when var == "Internal"
            puts var = "50"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_priority
        case var
        when var == "None"
            puts var = "10"
        when var == "Low"
            puts var = "20"
        when var == "Normal"
            puts var = "30"
        when var == "High"
            puts var = "40"
        when var == "Urgent"
            puts var = "50"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_typology_of_change
        case var
        when var == "New requirement"
            puts var = "new_requirement"
        when var == "Requirement updatable"
            puts var = "modif_requirement"
        when var == "Micro-change"
            puts var = "micro_change"
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_domain
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_origin
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_ci_objectives_2010_2011
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_ci_objectives_2012
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_ci_objectives_2013
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_ci_objectives_2014
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_quick_fix
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
        end
        var = format(var)
        return var
    end

    def list_level_of_impact
        case var
        when var == ""
            puts var = ""
        when var == ""
            puts var = ""
        else
            puts "null;"
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