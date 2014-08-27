require 'spreadsheet'

module LessonsLearnt

  include ApplicationHelper
 
  TEMPLATE_TYPE_ROW     = 0
  TEMPLATE_TYPE_COL     = 1



  def self.import(file)
    # Import excel file
    doc           = LessonsLearnt.load_lessons_excel_file(file)
    file_name     = LessonsLearnt.get_file_name(file)
    lessons       = doc.worksheet "Lessons learnt"
    actions       = doc.worksheet "Actions"
    assessments   = doc.worksheet "Assessment of quality service"
    template_type = LessonsLearnt.get_template_type(lessons)

    if template_type == APP_CONFIG['lesson_template_project']
      LessonsLearntProject.import(lessons, actions, assessments, file_name)
    elsif template_type == APP_CONFIG['lesson_template_ws']
      LessonsLearntWs.import(lessons, actions, assessments, file_name)
    elsif template_type == APP_CONFIG['lesson_template_plm']
      LessonsLearntPlm.import(lessons, actions, assessments, file_name)
    elsif template_type == APP_CONFIG['lesson_template_mt']
      LessonsLearntMt.import(lessons, actions, assessments, file_name)
    else
      Raise "Unknow Template type"
    end
  end

  def self.generate_file_header(template_type, pm, qwr, coc, suite, project, mt_qr)
    if template_type == APP_CONFIG['lesson_template_project']
      LessonsLearntProject.generate_file_header(pm, qwr, coc, suite, project)
    elsif template_type == APP_CONFIG['lesson_template_ws']
      LessonsLearntWs.generate_file_header(qwr, coc)
    elsif template_type == APP_CONFIG['lesson_template_plm']
      LessonsLearntPlm.generate_file_header(qwr, suite)
    elsif template_type == APP_CONFIG['lesson_template_mt']
      LessonsLearntMt.generate_file_header(mt_qr)
    else
      Raise "Unknow Template type"
    end
  end

  def self.generate_lesson_columns(template_type)
    if template_type == APP_CONFIG['lesson_template_project']
      LessonsLearntProject.generate_lesson_columns
    elsif template_type == APP_CONFIG['lesson_template_ws']
      LessonsLearntWs.generate_lesson_columns
    elsif template_type == APP_CONFIG['lesson_template_plm']
      LessonsLearntPlm.generate_lesson_columns
    elsif template_type == APP_CONFIG['lesson_template_mt']
      LessonsLearntMt.generate_lesson_columns
    else
      Raise "Unknow Template type"
    end
  end

  def self.generate_action_columns(template_type)
    if template_type == APP_CONFIG['lesson_template_project']
      LessonsLearntProject.generate_action_columns
    elsif template_type == APP_CONFIG['lesson_template_ws']
      LessonsLearntWs.generate_action_columns
    elsif template_type == APP_CONFIG['lesson_template_plm']
      LessonsLearntPlm.generate_action_columns
    elsif template_type == APP_CONFIG['lesson_template_mt']
      LessonsLearntMt.generate_action_columns
    else
      Raise "Unknow Template type"
    end
  end

  def self.generate_assessment_columns(template_type)
    if template_type == APP_CONFIG['lesson_template_project']
      LessonsLearntProject.generate_assessment_columns
    elsif template_type == APP_CONFIG['lesson_template_ws']
      LessonsLearntWs.generate_assessment_columns
    elsif template_type == APP_CONFIG['lesson_template_plm']
      LessonsLearntPlm.generate_assessment_columns
    elsif template_type == APP_CONFIG['lesson_template_mt']
      LessonsLearntMt.generate_assessment_columns
    else
      Raise "Unknow Template type"
    end
  end

  # Return an array of hash
  def self.generate_hash_export(files)
    hash_array = Array.new
    files.each do |file|
      hash_array << LessonsLearnt.generate_hash_export(file.lesson_collects, file.lesson_collect_actions, file.lesson_collect_assessments)
    end
    return hash_array
  end

  # Return an hash
  def self.generate_hash_export(lessons,actions,assessments)
    exportHash = Hash.new
    exportHash["lessonCollects"]          = lessons
    exportHash["lessonActions"]           = actions
    exportHash["lessonCollectAssessment"] = assessments
    return exportHash
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