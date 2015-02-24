require 'csv'

class CsvCi

  attr_accessor  :internal_id,
      :external_id,
      :ci_type,
      :stage,
      :category,
      :severity,
      :reproductibility,
      :summary,
      :description,
      :status,
      :submission_date,
      :reporter,
      :last_update,
      :last_update_person,
      :assigned_to,
      :priority,
      :visibility,
      :detection_version,
      :fixed_in_version,
      :status_precisions,
      :resolution_charge,
      :duplicated_id,
      :stages_to_reproduce,
      :additional_informations,
      :taking_into_account_date,
      :realisation_date,
      :realisation_author,
      :delivery_date,
      :reopening_date,
      :issue_origin,
      :detection_phase,
      :injection_phase,
      :real_test_of_detection,
      :theoretical_test_of_detection,
      :iteration,
      :lot,
      :entity,
      :team,
      :domain,
      :num_req_backlog,
      :origin,
      :output_type,
      :deliverables_list,
      :dev_team,
      :deployment,
      :airbus_responsible,
      :airbus_validation_date,
      :airbus_validation_date_objective,
      :airbus_validation_date_review,
      :ci_objective_20102011,
      :ci_objective_2012,
      :ci_objectives_2013,
      :deliverable_folder,
      :deployment_date,
      :deployment_date_objective,
      :specification_date,
      :kick_off_date,
      :launching_date_ddmmyyyy,
      :sqli_validation_date,
      :sqli_validation_date_objective,
      :specification_date_objective,
      :sqli_validation_responsible,
      :ci_objectives_2014,
      :linked_req,
      :quick_fix,
      :level_of_impact,
      :impacted_mnt_process,
      :path_backlog,
      :path_svn,
      :path_sfs_airbus,
      :item_type,
      :verification_date_objective,
      :verification_date,
      :request_origin,
      :issue_history,
      :ci_objectives_2014

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
    name.gsub!("&","n")
    name.gsub!(/\d\d\_/,"")
    #name.gsub!(/\_\d\d/ ,"")
    name = "internal_id" if name == "internal"
    name = "external_id" if name == "id"
    name
  end
end