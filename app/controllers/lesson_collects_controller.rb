require 'spreadsheet'
class LessonCollectsController < ApplicationController
  layout 'tools'         

  
  # --------
  # INDEX
  # --------
  def index
    # Params init
  	@lessonFiles    = nil
    @ws_array       = Array.new
    @suites_array   = Array.new
    @ws_selected    = -1
    @suite_selected = -1
    @imported       = params[:imported]

    # Params set
    if params[:ws_id] and params[:ws_id] != "-1"
      @ws_selected = params[:ws_id]
    end
    if params[:suite_id] and params[:suite_id] != "-1"
      @suite_selected = params[:suite_id]
    end

    # Workstream list 
  	ws_list   = Workstream.find(:all)
    @ws_array << ["ALL", -1]
    ws_list.each{ |ws| 
      @ws_array << [ws.name, ws.id]
    }

    # Suite tag list
    suite_list = SuiteTag.find(:all)
    @suites_array << ["ALL", -1]
    suite_list.each{ |suite|
      @suites_array << [suite.name, suite.id]
    }

    # Lesson list query conditions
    conditions = nil
    if (@ws_selected and @ws_selected != -1)
      ws_select_obj = Workstream.find(@ws_selected)
      if (ws_select_obj)
       conditions = "workstream like '%#{ws_select_obj.name}%'"
      end
    end

    if (@suite_selected and @suite_selected != -1)
      suite_select_obj = SuiteTag.find(@suite_selected)
      if (suite_select_obj)
        if (conditions)
          conditions << " AND suite_name like '%#{suite_select_obj.name}%'"
        else
          conditions = "suite_name like '%#{suite_select_obj.name}%'"
        end
      end
    end

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
