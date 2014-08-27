require 'spreadsheet'

module LessonsLearntPlm

  include ApplicationHelper

  # LESSON SHEET ROWS INDEX
  LESSON_BEGIN_HEADER               = 1
  LESSON_END_HEADER                 = 6
  LESSON_BEGIN_CONTENT              = 8
  
  # LESSON SHEET HEADER INDEX
  QWR_HEADER                        = "QWR/SQR :"
  SUITE_HEADER                      = "PLM Name"
  
  # LESSON SHEET CELLS INDEX
  LESSON_CELL_ID                    = 1 
  LESSON_CELL_MILESTONE             = 2
  LESSON_CELL_LESSON_LEARNT         = 3
  LESSON_CELL_TOPICS                = 4
  LESSON_CELL_PB_CAUSE              = 5
  LESSON_CELL_IMPROVEMENT           = 6
  LESSON_CELL_AXES                  = 7
  LESSON_CELL_SUB_AXES              = 8
  LESSON_CELL_PROJECT               = 9
  LESSON_CELL_ACTION_PLAN           = 10
  LESSON_CELL_ALREADY_EXIST         = 11
  LESSON_CELL_REDUNDANCY            = 12
  LESSON_CELL_SELECTED              = 13
  LESSON_CELL_ESCALATE              = 14
  LESSON_CELL_STATUS                = 15

  # LESSON SHEET CELLS LABEL
  LESSON_CELL_ID_LABEL              = "id"           
  LESSON_CELL_MILESTONE_LABEL       = "milestone"  
  LESSON_CELL_LESSON_LEARNT_LABEL   = "lesson_learnt"
  LESSON_CELL_TOPICS_LABEL          = "topics"     
  LESSON_CELL_PB_CAUSE_LABEL        = "pb_causes" 
  LESSON_CELL_IMPROVEMENT_LABEL     = "improvement" 
  LESSON_CELL_AXES_LABEL            = "axes"      
  LESSON_CELL_SUB_AXES_LABEL        = "sub_axes"
  LESSON_CELL_PROJECT_LABEL         = "project"
  LESSON_CELL_ACTION_PLAN_LABEL     = "action_plan"
  LESSON_CELL_ALREADY_EXIST_LABEL   = "already_exist"
  LESSON_CELL_REDUNDANCY_LABEL      = "redundancy"
  LESSON_CELL_SELECTED_LABEL        = "selected"
  LESSON_CELL_ESCALATE_LABEL        = "escalate"
  LESSON_CELL_STATUS_LABEL          = "status"

  # ACTION SHEET ROWS INDEX 
  ACTION_BEGIN_CONTENT              = 3

  # ACTION SHEET CELLS INDEX  
  ACTION_CELL_REF                   = 1
  ACTION_CELL_CREATION_DATE         = 2
  ACTION_CELL_SOURCE                = 3
  ACTION_CELL_TITLE                 = 4
  ACTION_CELL_STATUS                = 5
  ACTION_CELL_ACTIONNEE             = 6
  ACTION_CELL_DUE_DATE              = 7
  ACTION_CELL_BENEFIT               = 14
  ACTION_CELL_LEVEL_INVEST          = 15

  # ACTION SHEET CELLS LABEL
  ACTION_CELL_REF_LABEL             = "ref" 
  ACTION_CELL_CREATION_DATE_LABEL   = "creation_date"
  ACTION_CELL_SOURCE_LABEL          = "source"       
  ACTION_CELL_TITLE_LABEL           = "title"        
  ACTION_CELL_STATUS_LABEL          = "status"       
  ACTION_CELL_ACTIONNEE_LABEL       = "actionnee"
  ACTION_CELL_DUE_DATE_LABEL        = "due_date"     
  ACTION_CELL_BENEFIT_LABEL         = "benefit"
  ACTION_CELL_LEVEL_INVEST_LABEL    = "level_of_investment"

  # ASSESSMENT SHEET ROWS INDEX
  ASSESSMENT_BEGIN_CONTENT          = 3

  # ASSESSMENT SHEET CELLS INDEX
  ASSESSMENT_CELL_RMT_ID            = 0
  ASSESSMENT_CELL_MILESTONE         = 1
  ASSESSMENT_CELL_DET_PRES          = 2
  ASSESSMENT_CELL_QUAL_GATES        = 3
  ASSESSMENT_CELL_M_PREP            = 4
  ASSESSMENT_CELL_PROJ_SET_UP       = 5
  ASSESSMENT_CELL_LESSONS           = 6
  ASSESSMENT_CELL_SUPP              = 7
  ASSESSMENT_CELL_IMP               = 8
  ASSESSMENT_CELL_COMMENTS          = 9

  # ASSESSMENT SHEET CELLS LABEL
  ASSESSMENT_CELL_RMT_ID_LABEL      = "rmt_id"              
  ASSESSMENT_CELL_MILESTONE_LABEL   = "milestone"         
  ASSESSMENT_CELL_DET_PRES_LABEL    = "detailed_presentation"
  ASSESSMENT_CELL_QUAL_GATES_LABEL  = "quality_gates"       
  ASSESSMENT_CELL_M_PREP_LABEL      = "milestones_prep"     
  ASSESSMENT_CELL_PROJ_SET_UP_LABEL = "project_setting_up"  
  ASSESSMENT_CELL_LESSONS_LABEL     = "lessons_learnt"      
  ASSESSMENT_CELL_SUPP_LABEL        = "support_level"       
  ASSESSMENT_CELL_IMP_LABEL         = "improve_mt"          
  ASSESSMENT_CELL_COMMENTS_LABEL    = "comments" 

  # Return Array of arrays. One sub array represent one line of header
  def self.generate_file_header(qwr, suite)
    return [[QWR_HEADER, qwr],[SUITE_HEADER, suite]]
  end

  # Return the table name of columns
  def self.generate_lesson_columns
    return ["ID",
            "Milestone Of Collect",
            "Lesson learnt / Best Practice",
            "TOPICS (Observations / Fact / Problems)",
            "Problem Cause",
            "Improvement / Best Practices",
            "Analysis Axis",
            "Sub Axis Analysis",
            "Project name",
            "Action Plan at PLM level",
            "Already exists/New Practice",
            "Redundancy",
            "Selected by PLM?",
            "Will be escalated to M&T?",
            "Status"]
  end

  def self.generate_action_columns
    return ["Ref.",
            "Creation Date",
            "Source",
            "Title",
            "Status",
            "Actionee",
            "Due Date",
            "Completion Date",
            "Proof of realisation",
            "Comments",
            "KPI",
            "Risk/Issue Ref."
            "",
            "Benefit",
            "Level of investment"
          ]
  end

  def self.generate_assessment_columns
    return ["ID RMT (LL ticket)",
            "Milestone session",
            "Did you have a detailed presentation of the provided M&T quality activities?",
            "Quality Gates (BRD/TD)",
            "Milestones preparation",
            "Project Setting-up",
            "Lessons Learnt",
            "Support Level",
            "What could have been done to improve global M&T quality services?",
            "Comments"]
  end  

  def self.import(lessons, actions, assessments, file_name)
  	# Parse excel file
    lessons_header_hash       = LessonsLearntPlm.parse_lessons_excel_header(lessons)
    lessons_content_array     = LessonsLearntPlm.parse_lessons_excel_content(lessons)
    actions_content_array     = LessonsLearntPlm.parse_actions_excel_content(actions)
    assessments_content_array = LessonsLearntPlm.parse_assessments_content(assessments)

    # Create lesson file
    lesson_file               = LessonCollectFile.find(:first, :conditions => ["filename like ?", file_name])
    if (lesson_file == nil)
      lesson_file               = LessonCollectFile.new
    end
    lesson_file.qwr_sqr       = lessons_header_hash["qwr"]
    lesson_file.suite_name    = lessons_header_hash["suite"]
    lesson_file.filename      = file_name
    lesson_file.updated_at    = DateTime.now.to_date
    template_type = LessonCollectTemplateType.find(:first, :conditions=>["name LIKE ?",  APP_CONFIG['lesson_template_plm']])
    if template_type
      lesson_file.lesson_collect_template_type = template_type
    end
    lesson_file.save

 
    # Delete all existent data
    lesson_file.lesson_collects.each(&:destroy)
    lesson_file.lesson_collect_actions.each(&:destroy)
    lesson_file.lesson_collect_assessments.each(&:destroy)

    # Save lessons
    lessons_content_array.each do |l|
        lesson_collect = LessonCollect.new
        lesson_collect.lesson_collect_file_id = lesson_file.id
        lesson_collect.lesson_id              = l[LESSON_CELL_ID_LABEL]           
        lesson_collect.milestone              = l[LESSON_CELL_MILESTONE_LABEL]    
        lesson_collect.type_lesson            = l[LESSON_CELL_LESSON_LEARNT_LABEL]
        lesson_collect.topics                 = l[LESSON_CELL_TOPICS_LABEL]       
        lesson_collect.cause                  = l[LESSON_CELL_PB_CAUSE_LABEL]    
        lesson_collect.improvement            = l[LESSON_CELL_IMPROVEMENT_LABEL]
        lesson_collect.escalate_next_level    = l[LESSON_CELL_ESCALATE_LABEL]
        lesson_collect.project_name           = l[LESSON_CELL_PROJECT_LABEL]
        lesson_collect.action_plan            = l[LESSON_CELL_ACTION_PLAN_LABEL]
        lesson_collect.already_exist          = l[LESSON_CELL_ALREADY_EXIST_LABEL]
        lesson_collect.redundancy             = l[LESSON_CELL_REDUNDANCY_LABEL]
        lesson_collect.selected               = l[LESSON_CELL_SELECTED_LABEL]
        lesson_collect.status                 = l[LESSON_CELL_STATUS_LABEL]

        if  l[LESSON_CELL_AXES_LABEL]
          lesson_collect_axe = LessonCollectAxe.find(:first, :conditions => ["name LIKE ?", l[LESSON_CELL_AXES_LABEL]])
          if lesson_collect_axe
            lesson_collect.lesson_collect_axe = lesson_collect_axe
          end
        end

        if  l[LESSON_CELL_SUB_AXES_LABEL]
          lesson_collect_sub_axe = LessonCollectSubAxe.find(:first, :conditions => ["name LIKE ?", l[LESSON_CELL_SUB_AXES_LABEL]])
          if lesson_collect_sub_axe
            lesson_collect.lesson_collect_sub_axe = lesson_collect_sub_axe
          end
        end
        
        lesson_collect.save
    end

    # Save Actions
    actions_content_array.each do |a|
        lesson_collect_action = LessonCollectAction.new
        lesson_collect_action.lesson_collect_file_id  = lesson_file.id
        lesson_collect_action.ref                     = a[ACTION_CELL_REF_LABEL]          
        lesson_collect_action.creation_date           = a[ACTION_CELL_CREATION_DATE_LABEL]
        lesson_collect_action.source                  = a[ACTION_CELL_SOURCE_LABEL]       
        lesson_collect_action.title                   = a[ACTION_CELL_TITLE_LABEL]        
        lesson_collect_action.status                  = a[ACTION_CELL_STATUS_LABEL]       
        lesson_collect_action.actionne                = a[ACTION_CELL_ACTIONNEE_LABEL]       
        lesson_collect_action.due_date                = a[ACTION_CELL_DUE_DATE_LABEL]     
        lesson_collect_action.benefit                 = a[ACTION_CELL_BENEFIT_LABEL]      
        lesson_collect_action.level_of_investment     = a[ACTION_CELL_LEVEL_INVEST_LABEL]      
        lesson_collect_action.save
    end

    # Save Assessemnets
    assessments_content_array.each do |a|
        lesson_collect_assessment = LessonCollectAssessment.new
        lesson_collect_assessment.lesson_collect_file_id  = lesson_file.id
        lesson_collect_assessment.lesson_id               = a[ASSESSMENT_CELL_RMT_ID_LABEL]               
        lesson_collect_assessment.milestone               = a[ASSESSMENT_CELL_MILESTONE_LABEL]            
        lesson_collect_assessment.mt_detailed_desc        = a[ASSESSMENT_CELL_DET_PRES_LABEL]
        lesson_collect_assessment.quality_gates           = a[ASSESSMENT_CELL_QUAL_GATES_LABEL]        
        lesson_collect_assessment.milestones_preparation  = a[ASSESSMENT_CELL_MILESTONE_LABEL]      
        lesson_collect_assessment.project_setting_up      = a[ASSESSMENT_CELL_PROJ_SET_UP_LABEL]   
        lesson_collect_assessment.lessons_learnt          = a[ASSESSMENT_CELL_LESSONS_LABEL]       
        lesson_collect_assessment.support_level           = a[ASSESSMENT_CELL_SUPP_LABEL]        
        lesson_collect_assessment.mt_improvements         = a[ASSESSMENT_CELL_IMP_LABEL]           
        lesson_collect_assessment.comments                = a[ASSESSMENT_CELL_COMMENTS_LABEL]           
        lesson_collect_assessment.save  
    end
  end

  # ------------------------------------------------------------------------------------
  # IMPORT HELPERS
  # ------------------------------------------------------------------------------------


  # Lessons header
  # Return hash :
  #  lessons_header_hash["qwr"]     
  #  lessons_header_hash["suite"]   
  def self.parse_lessons_excel_header(consoSheet)
    next_cell_is_qwr     = false
    next_cell_is_suite   = false

    qwr_value     = nil
    suite_value   = nil


    for i in LESSON_BEGIN_HEADER..LESSON_END_HEADER do
      consoSheet.row(i).each do |header_cell|
        # Save the value of cell
        if next_cell_is_qwr
          qwr_value = header_cell
          next_cell_is_qwr = false
        elsif next_cell_is_suite
          suite_value = header_cell
          next_cell_is_suite = false
        end

        # Detect if the next cell contain header values
        if (header_cell.to_s == QWR_HEADER)
          next_cell_is_qwr = true
        elsif (header_cell.to_s == SUITE_HEADER)
          next_cell_is_suite = true
        end
        
      end
    end

    lessons_header_hash = Hash.new
    lessons_header_hash["qwr"]     = qwr_value
    lessons_header_hash["suite"]   = suite_value
    return lessons_header_hash
  end

  # Lessons content
  # Return Array of hashs
  # row_hash["id"]           
  # row_hash["milestone"]    
  # row_hash["lesson_learnt"]
  # row_hash["topics"]       
  # row_hash["pb_causes"]    
  # row_hash["improvement"]  
  # row_hash["axes"]         
  # row_hash["sub_axes"]      
  # row_hash["project"]     
  # row_hash["action_plan"]     
  # row_hash["already_exist"]     
  # row_hash["redundancy"]     
  # row_hash["selected"]     
  # row_hash["escalate"]     
  # row_hash["status"]    

  def self.parse_lessons_excel_content(consoSheet)
    # Var
    lessons_content_array = Array.new
    i = 0

    # Loop conso
    consoSheet.each do |conso_row|
      if ((i >= LESSON_BEGIN_CONTENT) and (conso_row[LESSON_CELL_ID]) and (conso_row[LESSON_CELL_ID].value) and (conso_row[LESSON_CELL_ID].value.length > 0))
        row_hash = Hash.new
        row_hash[LESSON_CELL_ID_LABEL]              = conso_row[LESSON_CELL_ID].value.to_s
        row_hash[LESSON_CELL_MILESTONE_LABEL]       = conso_row[LESSON_CELL_MILESTONE].to_s
        row_hash[LESSON_CELL_LESSON_LEARNT_LABEL]   = conso_row[LESSON_CELL_LESSON_LEARNT].to_s
        row_hash[LESSON_CELL_TOPICS_LABEL]          = conso_row[LESSON_CELL_TOPICS].to_s
        row_hash[LESSON_CELL_PB_CAUSE_LABEL]        = conso_row[LESSON_CELL_PB_CAUSE].to_s
        row_hash[LESSON_CELL_IMPROVEMENT_LABEL]     = conso_row[LESSON_CELL_IMPROVEMENT].to_s
        row_hash[LESSON_CELL_AXES_LABEL]            = conso_row[LESSON_CELL_AXES].to_s
        row_hash[LESSON_CELL_SUB_AXES_LABEL]        = conso_row[LESSON_CELL_SUB_AXES].to_s
        row_hash[LESSON_CELL_PROJECT_LABEL]         = conso_row[LESSON_CELL_PROJECT].to_s
        row_hash[LESSON_CELL_ACTION_PLAN_LABEL]     = conso_row[LESSON_CELL_ACTION_PLAN].to_s
        row_hash[LESSON_CELL_ALREADY_EXIST_LABEL]   = conso_row[LESSON_CELL_ALREADY_EXIST].to_s
        row_hash[LESSON_CELL_REDUNDANCY_LABEL]      = conso_row[LESSON_CELL_REDUNDANCY].to_s
        row_hash[LESSON_CELL_ESCALATE_LABEL]        = conso_row[LESSON_CELL_ESCALATE].to_s
        row_hash[LESSON_CELL_SELECTED_LABEL]        = conso_row[LESSON_CELL_SELECTED].to_s
        row_hash[LESSON_CELL_STATUS_LABEL]          = conso_row[LESSON_CELL_STATUS].to_s

        lessons_content_array << row_hash
      end
      i += 1
    end
    return lessons_content_array
  end


  # Actions content
  # Return Array of Hashs
  # row_hash["ref"]          
  # row_hash["creation_date"]
  # row_hash["source"]       
  # row_hash["title"]        
  # row_hash["status"]       
  # row_hash["actionnee"]       
  # row_hash["due_date"]        
  # row_hash["benefit"]        
  # row_hash["level_of_investment"]     
  def self.parse_actions_excel_content(consoSheet)
    # Var
    actions_content_array = Array.new
    i = 0

    # Loop conso
    consoSheet.each do |conso_row|
      if ((i >= ACTION_BEGIN_CONTENT )and (conso_row[ACTION_CELL_REF])  and (conso_row[ACTION_CELL_REF].value) and (conso_row[ACTION_CELL_REF].value.length > 0))
        row_hash = Hash.new
        row_hash[ACTION_CELL_REF_LABEL]           = conso_row[ACTION_CELL_REF].value.to_s
        row_hash[ACTION_CELL_CREATION_DATE_LABEL] = conso_row[ACTION_CELL_CREATION_DATE].to_s
        row_hash[ACTION_CELL_SOURCE_LABEL]        = conso_row[ACTION_CELL_SOURCE].to_s
        row_hash[ACTION_CELL_TITLE_LABEL]         = conso_row[ACTION_CELL_TITLE].to_s
        row_hash[ACTION_CELL_STATUS_LABEL]        = conso_row[ACTION_CELL_STATUS].to_s
        row_hash[ACTION_CELL_ACTIONNEE_LABEL]     = conso_row[ACTION_CELL_ACTIONNEE].to_s
        row_hash[ACTION_CELL_DUE_DATE_LABEL]      = conso_row[ACTION_CELL_DUE_DATE].to_s
        row_hash[ACTION_CELL_BENEFIT_LABEL]       = conso_row[ACTION_CELL_BENEFIT].to_s
        row_hash[ACTION_CELL_LEVEL_INVEST_LABEL]  = conso_row[ACTION_CELL_LEVEL_INVEST].to_s
        actions_content_array << row_hash
      end
      i += 1
    end
    return actions_content_array
  end

  # Assessments content
  # Return Array of Hashs
  # row_hash["rmt_id"]               
  # row_hash["milestone"]            
  # row_hash["detailed_presentation"]
  # row_hash["quality_gates"]        
  # row_hash["milestones_prep"]      
  # row_hash["project_setting_up"]   
  # row_hash["lessons_learnt"]       
  # row_hash["support_level"]        
  # row_hash["improve_mt"]           
  # row_hash["comments"]             
  def self.parse_assessments_content(consoSheet)
        # Var
    assessments_content_array = Array.new
    i = 0

    # Loop conso
    consoSheet.each do |conso_row|
      if ((i >= ASSESSMENT_BEGIN_CONTENT ) and (conso_row[ASSESSMENT_CELL_RMT_ID].to_s.size > 0))
        row_hash = Hash.new
        row_hash[ASSESSMENT_CELL_RMT_ID_LABEL]      = conso_row[ASSESSMENT_CELL_RMT_ID].to_s.gsub!('#',' ')
        row_hash[ASSESSMENT_CELL_MILESTONE_LABEL]   = conso_row[ASSESSMENT_CELL_MILESTONE].to_s
        row_hash[ASSESSMENT_CELL_DET_PRES_LABEL]    = conso_row[ASSESSMENT_CELL_DET_PRES].to_s
        row_hash[ASSESSMENT_CELL_QUAL_GATES_LABEL]  = conso_row[ASSESSMENT_CELL_QUAL_GATES].to_s
        row_hash[ASSESSMENT_CELL_M_PREP_LABEL]      = conso_row[ASSESSMENT_CELL_M_PREP].to_s
        row_hash[ASSESSMENT_CELL_PROJ_SET_UP_LABEL] = conso_row[ASSESSMENT_CELL_PROJ_SET_UP].to_s
        row_hash[ASSESSMENT_CELL_LESSONS_LABEL]     = conso_row[ASSESSMENT_CELL_LESSONS].to_s
        row_hash[ASSESSMENT_CELL_SUPP_LABEL]        = conso_row[ASSESSMENT_CELL_SUPP].to_s
        row_hash[ASSESSMENT_CELL_IMP_LABEL]         = conso_row[ASSESSMENT_CELL_IMP].to_s
        row_hash[ASSESSMENT_CELL_COMMENTS_LABEL]    = conso_row[ASSESSMENT_CELL_COMMENTS].to_s
        assessments_content_array << row_hash
      end
      i += 1
    end
    return assessments_content_array
  end

end