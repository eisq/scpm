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
    doc           = DeviationSvt.load_deviation_excel_file(file)
    file_name     = DeviationSvt.get_file_name(file)

    sheet_rows = "tab_error"

    if doc.worksheet "PSU_GPP" and lifecycle_id == 10
      psu = doc.worksheet "PSU_GPP"
      sheet_rows = self.parse_excel_content(psu)
    elsif doc.worksheet "PSU_LBIP" and lifecycle_id ==  9
      psu = doc.worksheet "PSU_LBIP"
      sheet_rows = self.parse_excel_content(psu)
    elsif doc.worksheet "PSU_Agile" and lifecycle_id == 8
      psu = doc.worksheet "PSU_Agile"
      sheet_rows = self.parse_excel_content(psu)
    end

    if doc.worksheet "PSU_GPP"
      Rails.logger.info("%%%%%%%%%% " + lifecycle_id.to_s)
    end

    return sheet_rows
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
    into_deliverables = true
    wrong_lifecycle = false
    activity_temp = activity = ""
    # Loop sheet
    sheet.each do |sheet_row|
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
      if (into_deliverables==true and sheet_row[CELL_1])
        if sheet_row[CELL_0] != "Macro-Activities"
          row_hash = Hash.new
          row_hash[CELL_ACTIVITY_LABEL]               = activity
          row_hash[CELL_MACRO_ACTIVITY_LABEL]         = sheet_row[CELL_0].to_s
          row_hash[CELL_DELIVERABLE_LABEL]            = sheet_row[CELL_1].to_s
          row_hash[CELL_METHODOLOGY_TEMPLATE_LABEL]   = sheet_row[CELL_2].to_s
          row_hash[CELL_IS_JUSTIFIED_LABEL]           = sheet_row[CELL_3].to_s
          row_hash[CELL_OTHER_TEMPLATE_LABEL]         = sheet_row[CELL_4].to_s
          row_hash[CELL_JUSTIFICATION_LABEL]          = sheet_row[CELL_5].to_s
          content_array << row_hash
        end
      else
        into_deliverables = false
        activity_temp = sheet_row[CELL_0]
      end

      if sheet_row[CELL_0] == "Objective"
        content_array = "wrong_psu_file"
      end
    end

    if content_array != "wrong_psu_file"
      content_array.each do |psu|
        if psu[CELL_DELIVERABLE_LABEL] == "" or psu[CELL_METHODOLOGY_TEMPLATE_LABEL] == "" or psu[CELL_MACRO_ACTIVITY_LABEL] == ""
          content_array = "empty_value"
          break
        elsif psu[CELL_METHODOLOGY_TEMPLATE_LABEL] =~ /#(.*)/ or psu[CELL_DELIVERABLE_LABEL] =~ /#(.*)/ or psu[CELL_MACRO_ACTIVITY_LABEL] =~ /#(.*)/
          content_array = "wrong_value_formula"
          break
        end
      end
    end

    return content_array
  end
end