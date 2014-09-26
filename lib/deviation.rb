require 'spreadsheet'

module Deviation

  include ApplicationHelper

  # SHEET CELLS INDEX  
  CELL_DELIVERABLE                  = 1
  CELL_METHODOLOGY_TEMPLATE         = 2
  CELL_IS_JUSTIFIED                 = 3
  CELL_OTHER_TEMPLATE               = 4
  CELL_JUSTIFICATION                = 5

  # SHEET CELLS LABEL
  CELL_DELIVERABLE_LABEL            = "Deliverables" 
  CELL_METHODOLOGY_TEMPLATE_LABEL   = "methodology_template"
  CELL_IS_JUSTIFIED_LABEL           = "is_justified"       
  CELL_OTHER_TEMPLATE_LABEL         = "other_template"        
  CELL_JUSTIFICATION_LABEL          = "justification"

  def self.import(file)
    # Import excel file
    doc           = Deviation.load_deviation_excel_file(file)
    file_name     = Deviation.get_file_name(file)
    psu       	  = doc.worksheet "PSU"
  end

  # ------------------------------------------------------------------------------------
  # IMPORT HELPERS
  # ------------------------------------------------------------------------------------

  # Load excel file and return the doc
  def self.load_deviation_excel_file(post)
    redirect_to '/project/index' and return if post.nil? or post['datafile'].nil?
    Spreadsheet.client_encoding = 'UTF-8'
    return Spreadsheet.open post['datafile']
  end

  def self.get_file_name(post)
    return post['datafile'].original_filename
  end

  def self.parse_excel_content(sheet)
    # Var
    content_array = Array.new
    deliverable = ""
    activity = ""

    # Loop sheet
    sheet.each do |sheet_row|
      if ((sheet_row[CELL_DELIVERABLE])  and (sheet_row[CELL_DELIVERABLE].value) and (sheet_row[CELL_DELIVERABLE].value.length > 0))
        row_hash = Hash.new
        row_hash[CELL_DELIVERABLE_LABEL]           = sheet_row[CELL_DELIVERABLE].value.to_s
        row_hash[CELL_METHODOLOGY_TEMPLATE_LABEL] = sheet_row[CELL_METHODOLOGY_TEMPLATE].to_s
        row_hash[CELL_IS_JUSTIFIED_LABEL]        = sheet_row[CELL_IS_JUSTIFIED].to_s
        row_hash[CELL_OTHER_TEMPLATE_LABEL]         = sheet_row[CELL_OTHER_TEMPLATE].to_s
        row_hash[CELL_JUSTIFICATION_LABEL]        = sheet_row[CELL_JUSTIFICATION].to_s
        content_array << row_hash
      end
    end
    return content_array
  end

end