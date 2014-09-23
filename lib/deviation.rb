require 'spreadsheet'

module Deviation

  include ApplicationHelper
 
  TEMPLATE_TYPE_ROW     = 0
  TEMPLATE_TYPE_COL     = 1

  def self.import(file)
    # Import excel file
    doc           = LessonsLearnt.load_lessons_excel_file(file)
    file_name     = LessonsLearnt.get_file_name(file)
    psu       	  = doc.worksheet "PSU"
  end

  # ------------------------------------------------------------------------------------
  # IMPORT HELPERS
  # ------------------------------------------------------------------------------------

  # Load excel file and return the doc
  def self.load_lessons_excel_file(post)
    redirect_to '/lesson_collects/index' and return if post.nil? or post['datafile'].nil?
    Spreadsheet.client_encoding = 'UTF-8'
    return Spreadsheet.open post['datafile']
  end

  def self.get_file_name(post)
    return post['datafile'].original_filename
  end

end