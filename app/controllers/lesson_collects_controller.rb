require 'spreadsheet'
class LessonCollectsController < ApplicationController
  layout 'tools'         

  
  # --------
  # INDEX
  # --------
  def index

    # -------
    # PARAMETERS
    # --------
    @imported         = params[:imported]
  	@lessonFiles      = nil
    @ws_array         = Array.new
    @suites_array     = Array.new
    @types_array      = Array.new
    @projects_array   = Array.new
    @axes_array       = Array.new
    @sub_axes_array   = Array.new
    @milestones_array = Array.new

    # -------
    # LISTS
    # --------

    # Workstream list 
  	ws_list   = Workstream.find(:all)
    ws_list.each{ |ws| 
      @ws_array << [ws.name, ws.id]
    }

    # Suite tag list
    suite_list = SuiteTag.find(:all)
    suite_list.each{ |suite|
      @suites_array << [suite.name, suite.id]
    }

    # Types list
    type_list = LessonCollectTemplateType.find(:all)
    type_list.each{ |type|
      @types_array << [type.name, type.id]
    }

    # Projects list
    project_list    = Project.find(:all, :conditions=>["is_running=1 and project_id IS NOT NULL"])
    @projects_array << ["None", -1]
    project_list.each{ |project|
      @projects_array << [project.name, project.id]
    }

    # Axes list
    axe_list    = LessonCollectAxe.find(:all)
    @axes_array << ["None", -1]
    axe_list.each{ |axe|
      @axes_array << [axe.name, axe.id]
    }

    # Sub Axes list
    sub_axe_list    = LessonCollectSubAxe.find(:all)
    @sub_axes_array << ["None", -1]
    sub_axe_list.each{ |sub_axe|
      @sub_axes_array << [sub_axe.name, sub_axe.id]
    }

    # Milestones
    milestone_list    = MilestoneName.find(:all, :conditions=>"is_active = 1")
    @milestones_array << ["None", -1]
    milestone_list.each{ |m|
      @milestones_array << [m.title, m.id]
    }

    # ------
    # FILTER
    # ------
    filter(params)
  end

  def filter(params)
    @filter_ws_selected         = Array.new
    @filter_suite_selected      = Array.new
    @filter_already_downloaded  = -1
    @filter_is_archived         = -1
    @filter_rise                = -1
    @filter_type_selected       = -1
    @filter_project_selected    = -1
    @filter_axe_selected        = -1
    @filter_sub_axe_selected    = -1
    @filter_milestone_selected  = -1
    @filter_begin_date          = nil
    @filter_end_date            = nil

    if params[:filter_ws]
      params[:filter_ws].each do |ws|
        @filter_ws_selected << ws.to_i
      end
    end
    if params[:filter_suite]
      params[:filter_suite].each do |suite|
        @filter_suite_selected << suite.to_i
      end
    end
    if params[:filter_type_id] and params[:filter_type_id] != "-1"
      @filter_type_selected = params[:filter_type_id]
    end
    if params[:filter_project_id] and params[:filter_project_id] != "-1"
      @filter_project_selected = params[:filter_project_id]
    end
    if params[:filter_axe_id] and params[:filter_axe_id] != "-1"
      @filter_axe_selected = params[:filter_axe_id]
    end
    if params[:filter_sub_axe_id] and params[:filter_sub_axe_id] != "-1"
      @filter_suite_selected = params[:filter_sub_axe_id]
    end
    if params[:filter_milestone_id] and params[:filter_milestone_id] != "-1"
      @filter_milestone_selected = params[:filter_milestone_id]
    end

    if params[:filter_already_downloaded] and params[:filter_already_downloaded] != "-1"
      @filter_already_downloaded = params[:filter_already_downloaded]
    else
      @filter_already_downloaded = false
    end

    if params[:filter_is_archived] and params[:filter_is_archived] != "-1"
      @filter_is_archived = params[:filter_is_archived]
    else
      @filter_is_archived = false
    end

    if params[:filter_rise] and params[:filter_rise] != "-1"
      @filter_rise = params[:filter_rise]
    else
      @filter_rise = false
    end

    if params[:filter_begin_date] and params[:filter_begin_date].length > 0
      @filter_begin_date = params[:filter_begin_date]
    end

    if params[:filter_end_date] and params[:filter_end_date].length > 0
      @filter_end_date = params[:filter_end_date]
    end


    # -------
    # QUERIES
    # --------

    joins_array = Array.new

    # Lesson list query conditions
    conditions = ""
    if @filter_ws_selected.size > 0
      conditions_open_parenthesis(conditions)
      filter_ws_select_objs = Workstream.find(:all, :conditions=>["id in (?)", @filter_ws_selected]).map {|ws| ws.name }
      filter_ws_select_objs.each do |ws_name|
        conditions_or(conditions)
        conditions << "workstream like '%#{ws_name}%'"
      end
      conditions_close_parenthesis(conditions)
    end

    # Suite list query
    if @filter_suite_selected.size > 0
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      filter_suite_select_objs = SuiteTag.find(:all, :conditions=>["id in (?)", @filter_suite_selected]).map {|s| s.name }
      filter_suite_select_objs.each do |s_name|
        conditions_or(conditions)
        conditions << "suite_name like '%#{s_name}%'"
      end
      conditions_close_parenthesis(conditions)
    end

    # Type
    if (@filter_type_selected and @filter_type_selected != -1)
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      filter_type_selected_obj = LessonCollectTemplateType.find(:first, :conditions => ["id = ?", @filter_type_selected])
      conditions << "lesson_collect_template_type_id = #{filter_type_selected_obj.id.to_s}"
      conditions_close_parenthesis(conditions)
    end

    # Already Downloaded
    if @filter_already_downloaded
      joins_array = joins_include(joins_array, "JOIN lesson_collect_file_downloads ON lesson_collect_files.id = lesson_collect_file_downloads.lesson_collect_file_id")
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "lesson_collect_file_downloads.user_id = #{current_user.id.to_s}"
      conditions_close_parenthesis(conditions)
    else  
      # downloaded_files_id = LessonCollectFileDownload.find(:all, :conditions => ["user_id = ?", current_user.id.to_s]).map {|d| d.id }
      # if downloaded_files_id.count > 0
      #   conditions_and(conditions)
      #   conditions_open_parenthesis(conditions)
      #   conditions << "lesson_collect_files.id NOT IN (#{downloaded_files_id.join(',')})"
      #   conditions_close_parenthesis(conditions)
      # end
    end

    # Archived
    if @filter_is_archived
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "is_archived = 1"
      conditions_close_parenthesis(conditions)
    else
      # conditions_and(conditions)
      # conditions_open_parenthesis(conditions)
      # conditions << "is_archived = 0"
      # conditions_close_parenthesis(conditions)
    end

    # RISE
    if @filter_rise
      joins_array = joins_include(joins_array, "JOIN lesson_collects ON lesson_collects.lesson_collect_file_id = lesson_collect_files.id")
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "lesson_collects.status = 'Published'"
      conditions_close_parenthesis(conditions)
    else
      # no_rise_files_id = LessonCollect.find(:all,:conditions=>"status = 'Published'", :group=>"lesson_collect_file_id").map {|lc| lc.lesson_collect_file_id }
      # if no_rise_files_id.count > 0
      #   conditions_and(conditions)
      #   conditions_open_parenthesis(conditions)
      #   conditions << "lesson_collect_files.id NOT IN (#{no_rise_files_id.join(',')})"
      #   conditions_close_parenthesis(conditions)
      # end
    end

    # Begin date
    if @filter_begin_date
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "lesson_collect_files.updated_at > '#{Date.parse(@filter_begin_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      conditions_close_parenthesis(conditions)
    end

    # End Date
    if @filter_end_date
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "lesson_collect_files.updated_at < '#{Date.parse(@filter_end_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      conditions_close_parenthesis(conditions)
    end

    # Axe
    if (@filter_axe_selected and @filter_axe_selected != -1)
      joins_array = joins_include(joins_array, "JOIN lesson_collects ON lesson_collects.lesson_collect_file_id = lesson_collect_files.id")
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "lesson_collects.lesson_collect_axe_id = #{@filter_axe_selected.to_s}"
      conditions_close_parenthesis(conditions)
    end

    # Sub Axe
    if (@filter_sub_axe_selected and @filter_sub_axe_selected != -1)
      joins_array = joins_include(joins_array, "JOIN lesson_collects ON lesson_collects.lesson_collect_file_id = lesson_collect_files.id")
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "lesson_collects.lesson_collect_sub_axe_id = #{@filter_sub_axe_selected.to_s}"
      conditions_close_parenthesis(conditions)
    end

    # Milestone
    if (@filter_milestone_selected and @filter_milestone_selected != -1)
      joins_array = joins_include(joins_array, "JOIN lesson_collects ON lesson_collects.lesson_collect_file_id = lesson_collect_files.id")
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      filter_milestone_selected_obj = MilestoneName.find(:first, :conditions => ["id = ?", @filter_milestone_selected])
      conditions << "lesson_collects.milestone LIKE '%#{filter_milestone_selected_obj.title.to_s}%'"
      conditions_close_parenthesis(conditions)
    end

    # Project name
    if (@filter_project_selected and @filter_project_selected != -1)
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      filter_project_selected_obj = Project.find(:first, :conditions => ["id = ?", @filter_project_selected])
      conditions << "lesson_collect_files.project_name LIKE '%#{filter_project_selected_obj.name}%'"
      conditions_close_parenthesis(conditions)
    end

    # Lesson list query
    if (conditions.length > 0)
      @lessonFiles = LessonCollectFile.find(:all, :joins=>joins_array, :conditions=>conditions, :group => "lesson_collect_files.id")
    else
      @lessonFiles = LessonCollectFile.find(:all)
    end
  end

  def filter_by_row(params)
    @filter_ws_selected         = Array.new
    @filter_suite_selected      = Array.new
    @filter_already_downloaded  = -1
    @filter_is_archived         = -1
    @filter_rise                = -1
    @filter_type_selected       = -1
    @filter_project_selected    = -1
    @filter_axe_selected        = -1
    @filter_sub_axe_selected    = -1
    @filter_milestone_selected  = -1
    @filter_begin_date          = nil
    @filter_end_date            = nil

    if params[:filter_ws]
      params[:filter_ws].each do |ws|
        @filter_ws_selected << ws.to_i
      end
    end
    if params[:filter_suite]
      params[:filter_suite].each do |suite|
        @filter_suite_selected << suite.to_i
      end
    end
    if params[:filter_type_id] and params[:filter_type_id] != "-1"
      @filter_type_selected = params[:filter_type_id]
    end
    if params[:filter_project_id] and params[:filter_project_id] != "-1"
      @filter_project_selected = params[:filter_project_id]
    end
    if params[:filter_axe_id] and params[:filter_axe_id] != "-1"
      @filter_axe_selected = params[:filter_axe_id]
    end
    if params[:filter_sub_axe_id] and params[:filter_sub_axe_id] != "-1"
      @filter_suite_selected = params[:filter_sub_axe_id]
    end
    if params[:filter_milestone_id] and params[:filter_milestone_id] != "-1"
      @filter_milestone_selected = params[:filter_milestone_id]
    end

    if params[:filter_already_downloaded] and params[:filter_already_downloaded] != "-1"
      @filter_already_downloaded = params[:filter_already_downloaded]
    else
      @filter_already_downloaded = false
    end

    if params[:filter_is_archived] and params[:filter_is_archived] != "-1"
      @filter_is_archived = params[:filter_is_archived]
    else
      @filter_is_archived = false
    end

    if params[:filter_rise] and params[:filter_rise] != "-1"
      @filter_rise = params[:filter_rise]
    else
      @filter_rise = false
    end

    if params[:filter_begin_date] and params[:filter_begin_date].length > 0
      @filter_begin_date = params[:filter_begin_date]
    end

    if params[:filter_end_date] and params[:filter_end_date].length > 0
      @filter_end_date = params[:filter_end_date]
    end


    # -------
    # QUERIES
    # --------

    lessons_joins_array     = Array.new
    actions_joins_array     = Array.new
    assessments_joins_array = Array.new

    # Lesson list query conditions
    lessons_conditions      = ""
    actions_conditions      = ""
    assessments_conditions  = ""


    lessons_joins_array = joins_include(lessons_joins_array, "JOIN lesson_collect_files ON lesson_collects.lesson_collect_file_id = lesson_collect_files.id")
    actions_joins_array = joins_include(actions_joins_array, "JOIN lesson_collect_files ON lesson_collect_actions.lesson_collect_file_id = lesson_collect_files.id")
    assessments_joins_array = joins_include(assessments_joins_array, "JOIN lesson_collect_files ON lesson_collect_assessments.lesson_collect_file_id = lesson_collect_files.id")

    if @filter_ws_selected.size > 0
      filter_ws_select_objs = Workstream.find(:all, :conditions=>["id in (?)", @filter_ws_selected]).map {|ws| ws.name }

      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
      filter_ws_select_objs.each do |ws_name|
        group_conditions_or(lessons_conditions, actions_conditions, assessments_conditions)
        lessons_conditions      << "lesson_collect_files.workstream like '%#{ws_name}%'"
        actions_conditions      << "lesson_collect_files.workstream like '%#{ws_name}%'"
        assessments_conditions  << "lesson_collect_files.workstream like '%#{ws_name}%'"
      end
      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
    end

    # Suite list query
    if @filter_suite_selected.size > 0
      filter_suite_select_objs = SuiteTag.find(:all, :conditions=>["id in (?)", @filter_suite_selected]).map {|s| s.name }

      group_conditions_and(lessons_conditions, actions_conditions, assessments_conditions)
      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
      filter_suite_select_objs.each do |s_name|
        group_conditions_or(lessons_conditions, actions_conditions, assessments_conditions)
        lessons_conditions      << "lesson_collect_files.suite_name like '%#{s_name}%'"
        actions_conditions      << "lesson_collect_files.suite_name like '%#{s_name}%'"
        assessments_conditions  << "lesson_collect_files.suite_name like '%#{s_name}%'"
      end
      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)

    end

    # Type
    if (@filter_type_selected and @filter_type_selected != -1)

      filter_type_selected_obj = LessonCollectTemplateType.find(:first, :conditions => ["id = ?", @filter_type_selected])

      group_conditions_and(lessons_conditions, actions_conditions, assessments_conditions)
      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
 
      lessons_conditions      << "lesson_collect_files.lesson_collect_template_type_id = #{filter_type_selected_obj.id.to_s}"
      actions_conditions      << "lesson_collect_files.lesson_collect_template_type_id = #{filter_type_selected_obj.id.to_s}"
      assessments_conditions  << "lesson_collect_files.lesson_collect_template_type_id = #{filter_type_selected_obj.id.to_s}"

      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)

    end

    # Already Downloaded
    if @filter_already_downloaded
      lessons_joins_array = joins_include(lessons_joins_array, "JOIN lesson_collect_file_downloads ON lesson_collect_files.id = lesson_collect_file_downloads.lesson_collect_file_id")
      actions_joins_array = joins_include(actions_joins_array, "JOIN lesson_collect_file_downloads ON lesson_collect_files.id = lesson_collect_file_downloads.lesson_collect_file_id")
      assessments_joins_array = joins_include(assessments_joins_array, "JOIN lesson_collect_file_downloads ON lesson_collect_files.id = lesson_collect_file_downloads.lesson_collect_file_id")
      
      group_conditions_and(lessons_conditions, actions_conditions, assessments_conditions)
      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
      lessons_conditions     << "lesson_collect_file_downloads.user_id = #{current_user.id.to_s}"
      actions_conditions     << "lesson_collect_file_downloads.user_id = #{current_user.id.to_s}"
      assessments_conditions << "lesson_collect_file_downloads.user_id = #{current_user.id.to_s}"
      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
    end

    # Archived
    if @filter_is_archived      
      group_conditions_and(lessons_conditions, actions_conditions, assessments_conditions)
      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
      lessons_conditions     << "lesson_collect_files.is_archived = 1"
      actions_conditions     << "lesson_collect_files.is_archived = 1"
      assessments_conditions << "lesson_collect_files.is_archived = 1"
      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
    end

    # RISE
    if @filter_rise
      conditions_and(lessons_conditions)
      conditions_open_parenthesis(lessons_conditions)
      conditions << "lesson_collects.status = 'Published'"
      conditions_close_parenthesis(lessons_conditions)
    end

    # Begin date
    if @filter_begin_date
      group_conditions_and(lessons_conditions, actions_conditions, assessments_conditions)
      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
      lessons_conditions      << "lesson_collect_files.updated_at > '#{Date.parse(@filter_begin_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      actions_conditions      << "lesson_collect_files.updated_at > '#{Date.parse(@filter_begin_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      assessments_conditions  << "lesson_collect_files.updated_at > '#{Date.parse(@filter_begin_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
    end

    # End Date
    if @filter_end_date
      group_conditions_and(lessons_conditions, actions_conditions, assessments_conditions)
      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
      lessons_conditions      << "lesson_collect_files.updated_at < '#{Date.parse(@filter_end_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      actions_conditions      << "lesson_collect_files.updated_at < '#{Date.parse(@filter_end_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      assessments_conditions  << "lesson_collect_files.updated_at < '#{Date.parse(@filter_end_date).strftime('%Y-%m-%d %H:%M:%S')}'"
      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
    end

    # Axe
    if (@filter_axe_selected and @filter_axe_selected != -1)
      conditions_and(lessons_conditions)
      conditions_open_parenthesis(lessons_conditions)
      lessons_conditions << "lesson_collects.lesson_collect_axe_id = #{@filter_axe_selected.to_s}"
      conditions_close_parenthesis(lessons_conditions)
    end

    # Sub Axe
    if (@filter_sub_axe_selected and @filter_sub_axe_selected != -1)
      conditions_and(lessons_conditions)
      conditions_open_parenthesis(lessons_conditions)
      lessons_conditions << "lesson_collects.lesson_collect_sub_axe_id = #{@filter_sub_axe_selected.to_s}"
      conditions_close_parenthesis(lessons_conditions)
    end

    # Milestone
    if (@filter_milestone_selected and @filter_milestone_selected != -1)
      filter_milestone_selected_obj = MilestoneName.find(:first, :conditions => ["id = ?", @filter_milestone_selected])

      conditions_and(lessons_conditions)
      conditions_open_parenthesis(lessons_conditions)
      lessons_conditions << "lesson_collects.milestone LIKE '%#{filter_milestone_selected_obj.title.to_s}%'"
      conditions_close_parenthesis(lessons_conditions)
    end

    # Project name
    if (@filter_project_selected and @filter_project_selected != -1)
      filter_project_selected_obj = Project.find(:first, :conditions => ["id = ?", @filter_project_selected])

      group_conditions_and(lessons_conditions, actions_conditions, assessments_conditions)
      group_conditions_open_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
      lessons_conditions      << "lesson_collect_files.project_name LIKE '%#{filter_project_selected_obj.name}%'"
      actions_conditions      << "lesson_collect_files.project_name LIKE '%#{filter_project_selected_obj.name}%'"
      assessments_conditions  << "lesson_collect_files.project_name LIKE '%#{filter_project_selected_obj.name}%'"
      group_conditions_close_parenthesis(lessons_conditions, actions_conditions, assessments_conditions)
    end

    # Lesson list query
    if (lessons_conditions.length > 0)
      @lessons      = LessonCollect.find(:all, :joins=>lessons_joins_array, :conditions=>lessons_conditions, :group => "lesson_collects.id")
    else
      @lessons      = LessonCollect.find(:all)
    end

    if (actions_conditions.length > 0)
      @actions      = LessonCollectAction.find(:all, :joins=>actions_joins_array, :conditions=>actions_conditions, :group => "lesson_collect_actions.id")
    else
      @actions      = LessonCollectAction.find(:all)
    end

    if (assessments_conditions.length > 0)
      @assessments  = LessonCollectAssessment.find(:all, :joins=>assessments_joins_array, :conditions=>assessments_conditions, :group => "lesson_collect_assessments.id")
    else
      @assessments  = LessonCollectAssessment.find(:all)
    end
  end


  # --------
  # DETAIL
  # --------
  def general_detail
    lesson_file_id = params[:id]
    if lesson_file_id != nil
      @lesson_collect_file = LessonCollectFile.find(:first, :conditions=>["id = ?", lesson_file_id])
      @last_download = LessonCollectFileDownload.find(:first, :conditions => ["lesson_collect_file_id = ? and user_id = ?", lesson_file_id, current_user.id], :order => "download_date desc")
    else
      redirect_to "/lesson_collects/index"
    end
  end

  def download_detail
    lesson_file_id = params[:id]
    if lesson_file_id != nil
      @lesson_collect_file = LessonCollectFile.find(:first, :conditions=>["id = ?", lesson_file_id])

    else
      redirect_to "/lesson_collects/index"
    end
  end

  def analysis_detail
    lesson_file_id = params[:id]
    if lesson_file_id != nil
      @lesson_collect_file = LessonCollectFile.find(:first, :conditions=>["id = ?", lesson_file_id])

    else
      redirect_to "/lesson_collects/index"
    end
  end

  def lesson_collect_file_comment_update
    lesson_file = LessonCollectFile.find(:first, :conditions=>["id = ?", params[:lesson_collect_file][:id]])
    if lesson_file.update_attributes(params[:lesson_collect_file])
      redirect_to(:action=>'general_detail', :id=>lesson_file.id.to_s)
    else
      redirect_to "/lesson_collects/index"
    end
  end

  def delete
    lesson_file_id = params[:id]
    if lesson_file_id != nil
      lesson_file = LessonCollectFile.find(:first, :conditions=>["id = ?", lesson_file_id])
      lesson_file.destroy
    end
    redirect_to "/lesson_collects/index"
  end

  # --------
  # IMPORT
  # -------- 
  def import_form
  end

  def import
    LessonsLearnt.import(params[:upload])
    redirect_to(:action=>'index', :imported=>1)
  end

  # --------
  # EXPORT
  # --------
  def export
    begin
      @xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
      
      # Filter
      filter_by_row(params)

      @filter_type_selected_obj = LessonCollectTemplateType.find(:first, :conditions => ["id = ?", @filter_type_selected])

      # Columns

      @header                  = LessonsLearnt.generate_file_header(@filter_type_selected_obj.name)
      @lessonCollectsHeader    = LessonsLearnt.generate_lesson_columns(@filter_type_selected_obj.name)
      @lessonActionsHeader     = LessonsLearnt.generate_action_columns(@filter_type_selected_obj.name)
      @lessonAssessmentsHeader = LessonsLearnt.generate_assessment_columns(@filter_type_selected_obj.name)

      @exportHash              = LessonsLearnt.generate_hash_export(@lessons, @actions, @assessments)

      headers['Content-Type']         = "application/vnd.ms-excel"
      headers['Content-Disposition']  = 'attachment; filename="lessons_learnt_collect_export.xls"'
      headers['Cache-Control']        = ''
      render(:layout=>false)
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
    end
  end
  
  # ------
  # HELPER
  # ------
  def conditions_and(conditions)
    if (conditions.length > 0 and conditions[-1,1] != "(")
      conditions << " and "
    end
    return conditions
  end

  def conditions_or(conditions)
    if (conditions.length > 0 and conditions[-1,1] != "(")
      conditions << " or "
    end
    return conditions
  end

  def conditions_open_parenthesis(conditions)
    conditions << '('
    return conditions
  end

  def conditions_close_parenthesis(conditions)
    conditions << ')'
    return conditions
  end

  def group_conditions_and(lesson_conditions, action_conditions, assessment_conditions)
    if (lesson_conditions and lesson_conditions.length > 0 and lesson_conditions[-1,1] != "(")
      lesson_conditions << " and "
    end
    if (action_conditions and action_conditions.length > 0 and action_conditions[-1,1] != "(")
      action_conditions << " and "
    end
    if (assessment_conditions and assessment_conditions.length > 0 and assessment_conditions[-1,1] != "(")
      assessment_conditions << " and "
    end
  end

  def group_conditions_or(lesson_conditions, action_conditions, assessment_conditions)
    if (lesson_conditions and lesson_conditions.length > 0 and lesson_conditions[-1,1] != "(")
      lesson_conditions << " or "
    end
    if (action_conditions and action_conditions.length > 0 and action_conditions[-1,1] != "(")
      action_conditions << " or "
    end
    if (assessment_conditions and assessment_conditions.length > 0 and assessment_conditions[-1,1] != "(")
      assessment_conditions << " or "
    end
  end

  def group_conditions_open_parenthesis(lesson_conditions, action_conditions, assessment_conditions)
    if (lesson_conditions)
      lesson_conditions << '('
    end
    if (action_conditions)
      action_conditions << '('
    end
    if (assessment_conditions)
      assessment_conditions << '('
    end
  end

  def group_conditions_close_parenthesis(lesson_conditions, action_conditions, assessment_conditions)
    if (lesson_conditions)
      lesson_conditions << ')'
    end
    if (action_conditions)
      action_conditions << ')'
    end
    if (assessment_conditions)
      assessment_conditions << ')'
    end
  end

  def joins_include(joins_array, join_str)
    if !joins_array.include? join_str
      joins_array << join_str
    end
    return joins_array
  end

end
