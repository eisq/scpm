require 'spreadsheet'

module LessonsLearnt

  include ApplicationHelper
 
  TEMPLATE_TYPE_ROW     = 0
  TEMPLATE_TYPE_COL     = 1
  TEMPLATE_TYPE_PROJECT = "PROJECT"
  TEMPLATE_TYPE_WS      = "WS"
  TEMPLATE_TYPE_PLM     = "PLM"
  TEMPLATE_TYPE_MT      = "MT"


  def self.import(file)
    # Import excel file
    doc         = LessonsLearnt.load_lessons_excel_file(file)
    lessons     = doc.worksheet LessonsLearntProject.WORKSHEET_LABEL_1
    actions     = doc.worksheet LessonsLearntProject.WORKSHEET_LABEL_2
    assessments = doc.worksheet LessonsLearntProject.WORKSHEET_LABEL_3
    file_name   = LessonsLearnt.get_file_name(file)
    template_type = LessonsLearnt.get_template_type(lessons)

    if template_type == TEMPLATE_TYPE_PROJECT
      LessonsLearntProject.import(lessons, actions, assessments, file_name)
    elsif template_type == TEMPLATE_TYPE_WS
      LessonsLearntWs.import(lessons, actions, assessments, file_name)
    elsif template_type == TEMPLATE_TYPE_PML
      LessonsLearntPmt.import(lessons, actions, assessments, file_name)
    elsif template_type == TEMPLATE_TYPE_MT
      LessonsLearntMt.import(lessons, actions, assessments, file_name)
    end
      
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

  def self.get_template_type(lessons)
    lessons.each do |conso_row|
      template_type = conso_row[TEMPLATE_TYPE_COL]
      return template_type
    end
  end

end