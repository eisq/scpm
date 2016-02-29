require 'spreadsheet'

module DeviationSvt

  include ApplicationHelper

  # SHEET CELLS INDEX
  CELL_0   = 0
  CELL_1   = 1
  CELL_2   = 2
  CELL_3   = 3
  CELL_4   = 4
  CELL_5   = 5

  # SHEET CELLS LABEL
  CELL_META_ACTIVITY_LABEL          = "meta_activity"
  CELL_ACTIVITY_LABEL               = "activity"
  CELL_MACRO_ACTIVITY_LABEL         = "macro_activity"
  CELL_DELIVERABLE_LABEL            = "deliverable"
  CELL_METHODOLOGY_TEMPLATE_LABEL   = "methodology_template"
  CELL_IS_JUSTIFIED_LABEL           = "is_justified"
  CELL_OTHER_TEMPLATE_LABEL         = "other_template"
  CELL_JUSTIFICATION_LABEL          = "justification"

  def self.import(file, lifecycle_id)
    # Import excel file
    doc           = DeviationSvf.load_deviation_excel_file(file)
    file_name     = DeviationSvf.get_file_name(file)

    sheet_error_type = "tab_error"

    if doc.worksheet "PSU_GPP" and lifecycle_id == 10
      psu = doc.worksheet "PSU_GPP"
      sheet_rows, sheet_error_type, sheet_error_lines = self.parse_excel_content(psu)
    elsif doc.worksheet "PSU_LBIP" and lifecycle_id ==  9
      psu = doc.worksheet "PSU_LBIP"
      sheet_rows, sheet_error_type, sheet_error_lines = self.parse_excel_content(psu)
    elsif doc.worksheet "PSU_Agile" and lifecycle_id == 8
      psu = doc.worksheet "PSU_Agile"
      sheet_rows, sheet_error_type, sheet_error_lines = self.parse_excel_content(psu)
    elsif doc.worksheet "PSU_Suite" and lifecycle_id == 7
      psu = doc.worksheet "PSU_Suite"
      sheet_rows, sheet_error_type, sheet_error_lines = self.parse_excel_content(psu)
    end

    return sheet_rows, sheet_error_type, sheet_error_lines
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
    content_array = Array.new
    error_type = ""
    error_lines = Array.new
    into_deliverables = true
    wrong_lifecycle = false
    activity_temp = activity = ""
    # Loop sheet

    #PSU line number
    line_number = 0

    sheet.each do |sheet_row|
    
      #Next line
      line_number += 1

      #We are in a row Activity
      if((into_deliverables==false) and sheet_row[CELL_0] and !sheet_row[CELL_1])
        activity_temp = sheet_row[CELL_0]
      end
      #We are in the row index for deliverables
      if (into_deliverables==false and sheet_row[CELL_0] and sheet_row[CELL_1] and (sheet_row[CELL_0]=="Macro-Activities"))
        into_deliverables = true
        activity = activity_temp
      end
      #We are in a row deliverable
      if (into_deliverables==true and sheet_row[CELL_1] or sheet_row[CELL_2])
        if sheet_row[CELL_0] != "Macro-Activities"
          row_hash = Hash.new
          row_hash[CELL_ACTIVITY_LABEL]               = activity
          row_hash[CELL_MACRO_ACTIVITY_LABEL]         = sheet_row[CELL_0].to_s
          row_hash[CELL_DELIVERABLE_LABEL]            = sheet_row[CELL_1].to_s
          row_hash[CELL_METHODOLOGY_TEMPLATE_LABEL]   = sheet_row[CELL_2].to_s
          row_hash[CELL_IS_JUSTIFIED_LABEL]           = sheet_row[CELL_3].to_s
          row_hash[CELL_OTHER_TEMPLATE_LABEL]         = sheet_row[CELL_4].to_s
          row_hash[CELL_JUSTIFICATION_LABEL]          = sheet_row[CELL_5].to_s

          #Check for any empty cell among the first three
          if sheet_row[CELL_0].to_s == "" or sheet_row[CELL_1].to_s == "" or sheet_row[CELL_2].to_s == ""
            error_type = "empty_value"
            error_lines << line_number
          #Check for any formula error among the first three
          elsif sheet_row[CELL_0].to_s =~ /#(.*)/ or sheet_row[CELL_1].to_s =~ /#(.*)/ or sheet_row[CELL_2].to_s =~ /#(.*)/
            error_type = "wrong_value_formula"
            break
          end

          content_array << row_hash
        end
      else
        into_deliverables = false
        activity_temp = sheet_row[CELL_0]
      end

      if sheet_row[CELL_0] == "Objective"
        error_type = "wrong_psu_file"
      end
    end

    return content_array, error_type, error_lines
  end
end