require 'csv'

class CsvCi

  attr_accessor  :internal_id, #Interne
    :external_id, #ID
    :type, #Type (new)
    :stage, #Etape
    :category, #Catégorie
    :severity, #Sévérité
    :reproducibility, #Reproductibilité (new)
    :summary, #Intitulé
    :description, #Description
    :status, #Etat
    :submission_date, #Soumission
    :reporter, #Rapporteur
    :last_update, #Mise à jour
    :last_update_person, #Personne dernière màj
    :assigned_to, #Assigné à
    :priority, #Priorité
    :visibility, #Visibilité
    :detection_version, #Version de détection (new)
    :version_taken_into_account, #Version de prise en compte (new)
    :status_precision, #Précision sur l'état (new)
    :resolution_charge, #Charge de résolution
    :id_duplicate, #Doublon d'ID (new)
    :steps_to_reproduce, #Etapes pour reproduire (new)
    :additional_information, #Informations complémentaires
    :taking_into_account_date, #Date de prise en compte
    :realisaton_date, #Date de réalisation
    :realisation_author, #Personne de réalisation
    :delivery_date, #Date de livraison
    :reopening_date, #Date de réouverture (new)
    :detection_phase, #Phase de détection (new)
    :injection_phase, #Phase d'injection (new)
    :impact, #Impact (en j/h) (new)
    :impact_time, #Impact en délai (en j) (new)
    :typology_of_change, #Typologie du changement (new)
    :deliverables_updated, #Livrables mis à jour (new)
    :iteration, #Itération (new)
    :lot, #Lot (new)
    :entity, #Entité (new)
    :team, #Equipe (new)
    :domain, #Domaine (new)
    :backlog_request_id, #Num Req Backlog (new)
    :origin, #Origin
    :improvement_target_objective, #Output Type
    :deliverable_list, #Deliverables list
    :accountable, #Dev Team
    :deployment, #Deployment
    :airbus_responsible, #Airbus Responsible
    :airbus_validation_date, #Airbus validation date
    :airbus_validation_date_objective, #Airbus validation date objective
    :airbus_validation_date_review, #Airbus validation Date Review
    :ci_objectives_2010_2011, #CI Objective 2010/2011 (new)
    :ci_objectives_2012, #CI Objective 2012 (new)
    :ci_objectives_2013, #CI Objectives 2013
    :deployment_date, #Deployment date
    :deployment_date_objective, #Deployment date objective
    :specification_date, #Specification date (new)
    :kick_off_date, #Kick-Off Date
    :launching_date_ddmmyyyy, #Launching date (dd/mm/yyyy)
    :sqli_validation_date, #SQLI Validation date
    :sqli_validation_date_objective, #SQLI Validation date objective
    :specification_date_objective, #Specification date Objective (new)
    :sqli_validation_responsible, #SQLI validation Responsible
    :ci_objectives_2014, #CI Objectives 2014 (new)
    :linked_req, #Linked Req (new)
    :quick_fix, #Quick Fix (new)
    :level_of_impact, #Level of Impact (new)
    :impacted_mnt_process, #Impacted M&T process (new)
    :path_backlog, #Path backlog (new)
    :deliverable_folder, #Path SVN
    :path_sfs_airbus, #Path SFS Airbus (new)
    :item_type, #Item Type (new)
    :verification_date_objective, #Verification Date Objective (new)
    :verification_date, #Verification Date (new)
    :request_origin, #Request Origin (new)
    :issue_history, #Historique du ticket
    :scope_l2,
    :sqli_validation_date_review,
    :deployment_date_review

  def initialize
  end

  def method_missing(m, *args, &block)
    #raise "CsvCi does not have a '#{m}' attribute/method"
  end

  def to_hash
    h = Hash.new
    self.instance_variables.each { |var|
      h[var[1..-1].to_sym] = self.instance_variable_get(var)
      }
    h
  end
end

class CsvCiReport

  attr_reader :projects

  def initialize(path)
    @path     = path
    @projects = []
    @columns  = Hash.new
  end

  def parse
    reader = CSV.open(@path, 'r')
    begin
      get_columns(reader.shift)
      if @columns.count > 1
       while not (row = reader.shift).empty?
         parse_row(row)
       end
      else
       raise "Incorrect data format"
      end
    rescue Exception => e
      if e.to_s == "CSV::IllegalFormatError"
        raise "Unexpected file format"
      else
        raise e
      end
    end

  end

private

  def get_columns(row)
    row.each_with_index { |r,i|
      @columns[sanitize_attr(r)] = i
      #puts sanitize_attr(r)
      #exit
      }
  end

  def parse_row(row)
    r = CsvCi.new
    @columns.each { |attr_name, index|
      #puts "#{attr_name} = '#{row[index]}'"
      begin
        eval("r.#{attr_name} = \"#{sanitize_value(row[index])}\"")  # r.id = row[1]
      rescue Exception => e
        raise "Error: #{e} attr_name=#{attr_name}, value=#{sanitize_value(row[index])}"
      end
      #eval("r.#{attr_name} = '#{row[index]}'")
      }
    @projects << r
  end

  def sanitize_value(value)
    return nil if !value
    value.gsub!("\"","'")
    value.gsub!("\\","\\\\\\\\")
    if value =~ /(\d\d)\/(\d\d)\/(\d\d\d\d)/
      value = "#{$2}/#{$1}/#{$3}"
    end
    value
  end

  def sanitize_attr(name)
    name = name.downcase
    name.gsub!(" #","")
    name.gsub!("/","")
    name.gsub!("  ","_")
    name.gsub!("(","")
    name.gsub!(")","")
    name.gsub!(" ","_")
    name.gsub!("-","_")
    name.gsub!(".","")
    name.gsub!(/\d\d\_/,"")
    #name.gsub!(/\_\d\d/ ,"")
    name = "internal_id" if name == "internal"
    name = "external_id" if name == "id"
    name
  end
end
