require 'csv'

class CsvBacklog

  attr_accessor  :id,
    :linked_req,
    :requirement,
    :origin,
    :description,
    :output_type,
    :impacted_mnt_process,
    :priority,
    :status,
    :submission_date,
    :dev_team,
    :planned_spec_date,
    :ticket_or_ci_ref,
    :planned_verification_date,
    :level_of_impact,
    :planned_acceptance_date,
    :target_qms_version,
    :planned_deployment_date,
    :target_perimeter,
    :spec_date,
    :verification_date,
    :acceptance_date,
    :deployment_date,
    :quick_fix,
    :comments

  def initialize
  end

  def method_missing(m, *args, &block)
    #raise "CsvBacklog does not have a '#{m}' attribute/method"
  end

  def to_hash
    h = Hash.new
    self.instance_variables.each { |var|
      h[var[1..-1].to_sym] = self.instance_variable_get(var)
      }
    h
  end
end

class CsvBacklogReport

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
    r = CsvBacklog.new
    @columns.each { |attr_name, index|
      #puts "#{attr_name} = '#{row[index]}'"
      begin
        eval("r.#{attr_name} = \"#{sanitize_value(row[index])}\"")  # r.id = row[1]
      rescue Exception => e
        raise "Error: #{e} attr_name=#{attr_name}, value=#{sanitize_value(row[index])}"
      end
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
    name
  end

end
