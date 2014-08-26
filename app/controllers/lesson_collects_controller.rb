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

    # Filters
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


    # -------
    # FILTERS 
    # --------
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
      downloaded_files_id = LessonCollectFileDownload.find(:all, :conditions => ["user_id = ?", current_user.id.to_s]).map {|d| d.id }
      if downloaded_files_id.count > 0
        conditions_and(conditions)
        conditions_open_parenthesis(conditions)
        conditions << "lesson_collect_files.id NOT IN (#{downloaded_files_id.join(',')})"
        conditions_close_parenthesis(conditions)
      end
    end

    # Archived
    if @filter_is_archived
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "is_archived = 1"
      conditions_close_parenthesis(conditions)
    else
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "is_archived = 0"
      conditions_close_parenthesis(conditions)
    end

    # RISE
    if @filter_rise
      joins_array = joins_include(joins_array, "JOIN lesson_collects ON lesson_collects.lesson_collect_file_id = lesson_collect_files.id")
      conditions_and(conditions)
      conditions_open_parenthesis(conditions)
      conditions << "lesson_collects.status = 'Published'"
      conditions_close_parenthesis(conditions)
    else
      no_rise_files_id = LessonCollect.find(:all,:conditions=>"status = 'Published'", :group=>"lesson_collect_file_id").map {|lc| lc.lesson_collect_file_id }
      if no_rise_files_id.count > 0
        conditions_and(conditions)
        conditions_open_parenthesis(conditions)
        conditions << "lesson_collect_files.id NOT IN (#{no_rise_files_id.join(',')})"
        conditions_close_parenthesis(conditions)
      end
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

  def delete
    lesson_file_id = params[:id]
    if lesson_file_id != nil
      lesson_file = LessonCollectFile.find(:first, :conditions=>["id = ?", lesson_file_id])
      lesson_file.destroy
    end
    redirect_to "/lesson_collects/index"
  end


  # --------
  # DETAIL
  # --------
  def general_detail
    lesson_file_id = params[:id]
    if lesson_file_id != nil
      @lesson_collect_file = LessonCollectFile.find(:first, :conditions=>["id = ?", lesson_file_id])

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
      # Variables
      @xml = Builder::XmlMarkup.new(:indent => 1) #Builder::XmlMarkup.new(:target => $stdout, :indent => 1)
      lessonFiles   = nil
      @ws_selected  = params[:ws_id_hidden]
      ws_select_obj = nil 
      @suite_selected = params[:suite_id_hidden]
      suite_select_obj = nil
      if @ws_selected and @ws_selected != "-1"
        ws_select_obj = Workstream.find(@ws_selected)
      end
      if @suite_selected and @suite_selected != "-1"
            suite_select_obj = SuiteTag.find(@suite_selected)
      end
      # Lesson files
      if (ws_select_obj and suite_select_obj)
       lessonFiles  = LessonCollectFile.find(:all, :conditions=>["workstream like ? and suite_name like ?", "%#{ws_select_obj.name}%","%#{suite_select_obj.name}%"])
      elsif (ws_select_obj)
       lessonFiles  = LessonCollectFile.find(:all, :conditions=>["workstream like ?", "%#{ws_select_obj.name}%"])
      elsif (suite_select_obj)
       lessonFiles  = LessonCollectFile.find(:all, :conditions=>["suite_name like ?", "%#{suite_select_obj.name}%"])
      else
       lessonFiles  = LessonCollectFile.find(:all)
      end

      # Data
      lessonCollects    = Array.new
      lessonActions     = Array.new
      lessonAssessments = Array.new
      @lessonCollectsHeader    = ["COC",
                                   "Suite Name",
                                   "Project Name",
                                   "Date of export",
                                   "PM",
                                   "QWR/SQR",
                                   "ID(Don't touch)",
                                   "Milestone of Collect",
                                   "Lesson learnt / Best Practice",
                                   "TOPICS(Observations / Fact / Problems)",
                                   "Pb cause",
                                   "Improvement / Best Practices",
                                   "Axes of anaylses",
                                   "Sub Axes"]

      @lessonActionsHeader     = ["COC",
                                  "Suite Name",
                                  "Project Name",
                                  "Date of export",
                                  "PM","QWR/SQR",
                                  "Ref.(Don’t touch)",
                                  "Creation Date",
                                  "Source",
                                  "Title",
                                  "Status",
                                  "Actionn",
                                  "Due Date"]

      @lessonAssessmentsHeader = ["COC",
                                  "Suite Name",
                                  "Project Name",
                                  "Date of export",
                                  "PM",
                                  "QWR/SQR",
                                  "ID RMT (LL ticket)",
                                  "Milestone session",
                                  "Did you have a detailed presentation of the provided M&T quality activities?",
                                  "Quality Gates (BRD/TD)",
                                  "Milestones preparation",
                                  "Project Setting-up",
                                  "Lessons Learnt",
                                  "Support Level",
                                  "What could have been done to improve global M&T quality services?",
                                  "Comments"]

      @exportArray = Array.new
      lessonFiles.each do |lf|
        exportHash = Hash.new
        exportHash["file"] = lf
        exportHash["lessonCollects"]          = LessonCollect.find(:all, :conditions=>["lesson_collect_file_id = ?", lf.id])
        exportHash["lessonActions"]           = LessonCollectAction.find(:all, :conditions=>["lesson_collect_file_id = ?", lf.id])
        exportHash["lessonCollectAssessment"] = LessonCollectAssessment.find(:all, :conditions=>["lesson_collect_file_id = ?", lf.id])
        @exportArray << exportHash
      end

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

  def joins_include(joins_array, join_str)
    if !joins_array.include? join_str
      joins_array << join_str
    end
    return joins_array
  end

end
