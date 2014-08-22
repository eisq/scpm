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
    doc           = LessonsLearnt.load_lessons_excel_file(file)
    file_name     = LessonsLearnt.get_file_name(file)
    lessons       = doc.worksheet "Lessons learnt"
    actions       = doc.worksheet "Actions"
    assessments   = doc.worksheet "Assessment of quality service"
    template_type = LessonsLearnt.get_template_type(lessons)

    Rails.logger.info "CDB DEBUG"
    Rails.logger.info "---"+template_type.to_s
    if template_type == TEMPLATE_TYPE_PROJECT
      Rails.logger.info "Case 1"
      LessonsLearntProject.import(lessons, actions, assessments, file_name)
    elsif template_type == TEMPLATE_TYPE_WS
      Rails.logger.info "Case 2"
      LessonsLearntWs.import(lessons, actions, assessments, file_name)
    elsif template_type == TEMPLATE_TYPE_PLM
      Rails.logger.info "Case 3"
      LessonsLearntPmt.import(lessons, actions, assessments, file_name)
    elsif template_type == TEMPLATE_TYPE_MT
      Rails.logger.info "Case 4"
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