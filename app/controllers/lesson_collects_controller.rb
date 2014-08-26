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
    @imported       = params[:imported]
  	@lessonFiles    = nil
    @ws_array       = Array.new
    @suites_array   = Array.new
    @types_array    = Array.new
    @projects_array = Array.new
    @axes_array     = Array.new
    @sub_axes_array = Array.new

    # Filters
    @filter_ws_selected         = Array.new
    @filter_suite_selected      = Array.new
    @filter_already_downloaded  = -1
    @filter_type_selected       = -1
    @filter_project_selected    = -1
    @filter_axe_selected        = -1
    @filter_sub_axe_selected    = -1


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

    if params[:filter_already_downloaded] and params[:filter_already_downloaded]!= "-1"
      @filter_already_downloaded = params[:filter_already_downloaded]
    else
      @filter_already_downloaded = false
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
    project_list = Project.find(:all, :conditions=>["is_running=1 and project_id IS NOT NULL"])
    project_list.each{ |project|
      @projects_array << [project.name, project.id]
    }

    # Axes list
    axe_list = LessonCollectAxe.find(:all)
    axe_list.each{ |axe|
      @axes_array << [axe.name, axe.id]
    }

    # Sub Axes list
    sub_axe_list = LessonCollectSubAxe.find(:all)
    sub_axe_list.each{ |sub_axe|
      @sub_axes_array << [sub_axe.name, sub_axe.id]
    }

    # -------
    # QUERIES
    # --------

    # Lesson list query conditions
    conditions = nil
    # if (@filter_ws_selected and @filter_ws_selected != -1)
    #   filter_ws_select_obj = Workstream.find(@filter_filter_ws_selected)
    #   if (filter_ws_select_obj)
    #    conditions = "workstream like '%#{filter_ws_select_obj.name}%'"
    #   end
    # end

    # # Suite list query
    # if (@filter_suite_selected and @filter_suite_selected != -1)
    #   filter_suite_select_obj = SuiteTag.find(@filter_suite_selected)
    #   if (filter_suite_select_obj)
    #     if (conditions)
    #       conditions << " AND suite_name like '%#{filter_suite_select_obj.name}%'"
    #     else
    #       conditions = "suite_name like '%#{filter_suite_select_obj.name}%'"
    #     end
    #   end
    # end

    # Lesson list query
    if (conditions)
      @lessonFiles = LessonCollectFile.find(:all, :conditions=>conditions)
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
  
end
