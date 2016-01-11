require 'google_chart'
require 'spreadsheet'

class ToolsController < ApplicationController

  Spider_counter_struct    = Struct.new(:historycounter, :spider_version)

  if APP_CONFIG['project_name']=='EISQ'
    layout 'tools'
  else
    layout 'mp_tools'
  end

  include WelcomeHelper

  def index
  end

  def stats_open_projects
    @xml = Builder::XmlMarkup.new(:indent => 1)
    @stats = []
    # global stats
    tmp_projects  = Request.find(:all, :conditions=>"status !='cancelled' and status != 'to be validated'")
    @workpackages = tmp_projects.map{|r| r.project_name + " / " + get_workpackage_name_from_summary(r.summary, 'No WP')}.uniq.sort
    @projects     = tmp_projects.map{|r| r.project_name}.uniq.sort
    begin
      month_loop(5,2010) { |d|
        requests = Request.find(:all, :conditions=>"date_submitted <= '#{d.to_s}' and status!='to be validated' and status!='cancelled'")
        a = requests.size
        b = requests.map{|r| r.project_name}.uniq.size # work also with a simple group by clause
        c = requests.map{|r| r.project_name + " " + get_workpackage_name_from_summary(r.summary, 'No WP')}.uniq.size
        @stats << [d, a,b,c]
        }
    rescue Exception => e
      render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
      return
    end

    # by centres
    @workstreams = Workstream.all()
    @workstreams = @workstreams.map { |ws| ws.name }
    @centres = []
    for centre in @workstreams do
      stats = Array.new
      @centres << {:name=>centre, :stats=>stats}
      begin
        month_loop(5,2010) { |d|
          requests = Request.find(:all, :conditions=>"workstream='#{centre}' and date_submitted <= '#{d.to_s}' and status!='to be validated' and status!='cancelled'")
          a = requests.size
          b = requests.map{|r| r.project_name}.uniq.size # work also with a simple group by clause
          c = requests.map{|r| r.project_name + " " + get_workpackage_name_from_summary(r.summary, 'No WP')}.uniq.size

          stats << [d, a,b,c]
          }
      rescue Exception => e
        render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
        return
      end
      #puts "#{centre}: #{stats.size}"
    end
    headers['Content-Type'] = "application/vnd.ms-excel"
    headers['Content-Disposition'] = 'attachment; filename="Stats.xls"'
    headers['Cache-Control'] = ''
    render(:layout=>false)
  end

  def test_email
    Mailer::deliver_mail(APP_CONFIG['test_email_address'])
  end

  def scripts
  end

  def execute_from_spider_to_svt
    i=0
    DeviationActivity.find(:all).each do |spider|
      i=i+1
      svt_to_fill = SvtDeviationActivity.new
      svt_to_fill.id = spider.id
      svt_to_fill.name = spider.name
      svt_to_fill.is_active = spider.is_active
      svt_to_fill.svt_deviation_meta_activity_id = spider.deviation_meta_activity_id
      svt_to_fill.save
    end
    @number_deviation_activity = i

    i=0
    DeviationActivityDeliverable.find(:all).each do |spider|
      i=i+1
      svt_to_fill = SvtDeviationActivityDeliverable.new
      svt_to_fill.id = spider.id
      svt_to_fill.svt_deviation_activity_id = spider.deviation_activity_id
      svt_to_fill.svt_deviation_deliverable_id = spider.deviation_deliverable_id
      svt_to_fill.save
    end
    @number_deviation_activity_deliverable = i

    i=0
    DeviationDeliverable.find(:all).each do |spider|
      i=i+1
      svt_to_fill = SvtDeviationDeliverable.new
      svt_to_fill.id = spider.id
      svt_to_fill.name = spider.name
      svt_to_fill.is_active = spider.is_active
      svt_to_fill.save
    end
    @number_deviation_deliverable = i

    i=0
    DeviationMetaActivity.find(:all).each do |spider|
      i=i+1
      svt_to_fill = SvtDeviationMetaActivity.new
      svt_to_fill.id = spider.id
      svt_to_fill.name = spider.name
      svt_to_fill.is_active = spider.is_active
      svt_to_fill.meta_index = spider.meta_index
      svt_to_fill.save
    end
    @number_deviation_meta_activity = i

    i=0
    DeviationQuestionLifecycle.find(:all).each do |spider|
      i=i+1
      svt_to_fill = SvtDeviationQuestionLifecycle.new
      svt_to_fill.id = spider.id
      svt_to_fill.svt_deviation_question_id = spider.deviation_question_id
      svt_to_fill.lifecycle_id = spider.lifecycle_id
      svt_to_fill.save
    end
    @number_deviation_question_lifecycle = i

    i=0
    DeviationQuestionMilestoneName.find(:all).each do |spider|
      i=i+1
      svt_to_fill = SvtDeviationQuestionMilestoneName.new
      svt_to_fill.id = spider.id
      svt_to_fill.svt_deviation_question_id = spider.deviation_question_id
      svt_to_fill.milestone_name_id = spider.milestone_name_id
      svt_to_fill.save
    end
    @number_deviation_question_milestone_name = i

    i=0
    DeviationQuestion.find(:all).each do |spider|
      i=i+1
      svt_to_fill = SvtDeviationQuestion.new
      svt_to_fill.id = spider.id
      svt_to_fill.svt_deviation_deliverable_id = spider.deviation_deliverable_id
      svt_to_fill.svt_deviation_activity_id = spider.deviation_activity_id
      svt_to_fill.question_text = spider.question_text
      svt_to_fill.is_active = spider.is_active
      svt_to_fill.answer_reference = spider.answer_reference
      svt_to_fill.save
    end
    @number_deviation_question = i

    redirect_to '/tools/scripts'
  end

  def remove_false
    SvtDeviationQuestion.find(:all, :conditions=>["is_active = ?", false]).each do |to_delete|
      to_delete.delete
    end
    SvtDeviationDeliverable.find(:all, :conditions=>["is_active = ?", false]).each do |to_delete|
      to_delete.delete
    end
    SvtDeviationActivity.find(:all, :conditions=>["is_active = ?", false]).each do |to_delete|
      to_delete.delete
    end
    SvtDeviationMetaActivity.find(:all, :conditions=>["is_active = ?", false]).each do |to_delete|
      to_delete.delete
    end
    SvtDeviationMacroActivity.find(:all, :conditions=>["is_active = ?", false]).each do |to_delete|
      to_delete.delete
    end

    redirect_to '/tools/scripts'
  end

  def change_svt_id
    #Create the new starting reference
    svt_spider = SvtDeviationSpider.new
    svt_spider.id = 30000
    svt_spider.save

    #migrate all existing svt_spiders
    i = 0
    SvtDeviationSpider.find(:all, :conditions=>["id < 30000"]).each do |spider|
      i = i + 1
      new_spider = SvtDeviationSpider.new
      new_spider.id = (30000 + i)
      new_spider.milestone_id = spider.milestone_id
      new_spider.impact_count = spider.impact_count
      new_spider.created_at = spider.created_at
      new_spider.updated_at = spider.updated_at
      new_spider.file_link = spider.file_link
      new_spider.save

      SvtDeviationSpiderConsolidation.find(:all, :conditions=>["svt_deviation_spider_id = ?", spider.id]).each do |conso|
        conso.svt_deviation_spider_id = new_spider.id
        conso.save
      end

      SvtDeviationSpiderDeliverable.find(:all, :conditions=>["svt_deviation_spider_id = ?", spider.id]).each do |deliv|
        deliv.svt_deviation_spider_id = new_spider.id
        deliv.save
      end

      SvtDeviationSpiderActivityValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", spider.id]).each do |activ_val|
        activ_val.svt_deviation_spider_id = new_spider.id
        activ_val.save
      end

      SvtDeviationSpiderDeliverableValue.find(:all, :conditions=>["svt_deviation_spider_id = ?", spider.id]).each do |deliv_val|
        deliv_val.svt_deviation_spider_id = new_spider.id
        deliv_val.save
      end

      SvtDeviationSpiderConsolidationTemp.find(:all, :conditions=>["svt_deviation_spider_id = ?", spider.id]).each do |conso_temp|
        conso_temp.svt_deviation_spider_id = new_spider.id
        conso_temp.save
      end

      spider.delete
    end

    redirect_to '/tools/scripts'
  end

  def fill_project_id
    DeviationSpider.find(:all).each do |spider|
      if spider.id > 10000 and spider.id < 30000 and spider.milestone
        spider.project_id = spider.milestone.project_id
        spider.save
      end
    end

    redirect_to '/tools/scripts'
  end

  def fill_svt_project_id
    SvtDeviationSpider.find(:all).each do |spider|
      if spider.id > 30000 and spider.milestone
        spider.project_id = spider.milestone.project_id
        spider.save
      end
    end

    redirect_to '/tools/scripts'
  end

  def add_standard_project_for_avv
    project = Project.new
    project.id = 10000
    project.save

    redirect_to '/tools/scripts'
  end

  def sdp_import
  end

  def do_sdp_upload
    post = params[:upload]
    conf = params[:conf]
    project = params[:project]
    redirect_to '/tools/sdp_import' and return if post.nil? or post['datafile'].nil?
    name =  post['datafile'].original_filename
    directory = "public/data"
    path = File.join(directory, name)
    File.open(path, "wb") { |f| f.write(post['datafile'].read) }
    sdp = SDP.new(path)
    begin
      sdp.import(conf, {:project=>project})
      SDPTask.find(:all, :conditions=>["iteration is not null"]).map{|sdp| {:name=>sdp.iteration, :project_code=>sdp.project_code}}.uniq.each { |f|
        if Iteration.find_by_name_and_project_code(f[:name], f[:project_code]).nil?
          Iteration.create(f)
        end
      }
      if APP_CONFIG['use_multiple_projects_sdp_export']
        redirect_to '/tools/mp_sdp_index'
        return
      end

      sdp_index_prepare
      sdp_index_by_type_prepare
      SdpImportLog.create(
          :sdp_initial_balance             => @sdp_initial_balance,
          :sdp_real_balance                => @real_balance,
          :sdp_real_balance_and_provisions => @real_balance_and_provisions,
          :operational_total_minus_om      => @operational_total-@operational_percent_total,
          :not_included_remaining          => @not_included_remaining,
          :provisions                      => @provisions_remaining_should_be,
          :sold                            => @sold,
          :remaining_time                  => @remaining_time
          )
      sdp_graph # aleady in sdp_index_prepare, but repeated here so grap in email is updated
      history_comparison
      @sdp_index_by_mail = true    
      body = render_to_string(:action=>'sdp_index', :layout=>false) + render_to_string(:action=>'sdp_index_by_type', :layout=>false)
      Mailer::deliver_mail(APP_CONFIG['sdp_import_email_destination'],APP_CONFIG['sdp_import_email_object'],"<b>SDP has been updated by #{current_user.name}</b><br/><br/>"+body)
      redirect_to '/tools/sdp_index'
    rescue Exception => e
      render(:text=>e)
    end
  end

  def sdp_index_prepare
    return if SDPTask.count.zero?
    begin
      @nb_qr                             = SdpConstant.find(:first, :conditions=>["constant_name = ?", "NB_QR"])
      @fte                               = SdpConstant.find(:first, :conditions=>["constant_name = ?", "NB_FTE"])
      nb_days_per_month                  = SdpConstant.find(:first, :conditions=>["constant_name = ?", "NB_DAYS_PER_MONTH"])
      meetings_load_per_month            = SdpConstant.find(:first, :conditions=>["constant_name = ?", "MEETINGS_LOAD_PER_MONTH"])
      pm_load_per_month                  = SdpConstant.find(:first, :conditions=>["constant_name = ?", "PM_LOAD_PER_MONTH"]) #was: NB_DAYS_PER_MONTH*2 + NB_DAYS_PER_MONTH/1.5 # CP + PMO + DP
      wp_leaders_days_per_month          = SdpConstant.find(:first, :conditions=>["constant_name = ?", "WP_LEADERS_DAYS_PER_MONTH"]) #was: 18 # 10 + 4*2

      @phases                            = SDPPhase.all
      @provisions                        = SDPTask.find(:all, :conditions=>"iteration='P'", :order=>'title')
      @sdp_initial_balance               = @phases.inject(0) { |sum, p| p.balancei+sum}
      tasks2010                          = SDPTask.find(:all, :conditions=>"iteration='2010'")
      tasks2011                          = SDPTask.find(:all, :conditions=>"iteration='2011'")
      tasks2012                          = SDPTask.find(:all, :conditions=>"iteration='2012'")
      tasks2013                          = SDPTask.find(:all, :conditions=>"iteration='2013'")
      tasks2014                          = SDPTask.find(:all, :conditions=>"iteration='2014'")
      tasks2016                          = SDPTask.find(:all, :conditions=>"iteration='2016'")
      op2010                             = tasks2010.inject(0) { |sum, t| t.initial+sum}
      op2011                             = tasks2011.inject(0) { |sum, t| t.initial+sum}
      op2012                             = tasks2012.inject(0) { |sum, t| t.initial+sum}
      op2013                             = tasks2013.inject(0) { |sum, t| t.initial+sum}
      op2014                             = tasks2014.inject(0) { |sum, t| t.initial+sum}
      op2016                             = tasks2016.inject(0) { |sum, t| t.initial+sum}
      @operational2011_10percent         = round_to_hour(op2011*0.11111111111) # reciprocal of 9% (7,2% on total budget)
      @operational2012_10percent         = round_to_hour(op2012*0.11111111111)
      @operational2013_10percent         = round_to_hour(op2013*0.11111111111)
      @operational2014_10percent         = round_to_hour(op2014*0.11111111111)
      @operational2016_10percent         = 0 # round_to_hour(op2016*0.02040816) # reciprocal of 2,5% (~2% on total budget)
      @operational_percent_total         = @operational2011_10percent + @operational2012_10percent + @operational2013_10percent + @operational2014_10percent + @operational2016_10percent
      @operational_total_2011            = op2010 + op2011 + @operational2011_10percent
      @operational_total_2012            = op2012 + @operational2012_10percent
      @operational_total_2013            = op2013 + @operational2013_10percent
      @operational_total_2014            = op2014 + @operational2014_10percent
      @operational_total_2016            = op2016 + @operational2016_10percent
      @operational_total                 = @operational_total_2011 + @operational_total_2012 + @operational_total_2013 + @operational_total_2014 + @operational_total_2016
      @remaining                         = (tasks2010.inject(0) {|sum, t| t.remaining+sum} + tasks2011.inject(0) {|sum, t| t.remaining+sum} + tasks2012.inject(0) {|sum, t| t.remaining+sum} + tasks2013.inject(0) {|sum, t| t.remaining+sum} + tasks2014.inject(0) {|sum, t| t.remaining+sum} + tasks2016.inject(0) {|sum, t| t.remaining+sum})
      @remaining_time                    = (@remaining/@fte.constant_value/nb_days_per_month.constant_value/0.001).round * 0.001
      @phases.each { |p|  p.gain_percent = (p.initial==0) ? 0 : (p.balancei/p.initial*100/0.1).round * 0.1 }
      @theorical_management              = round_to_hour((pm_load_per_month.constant_value + meetings_load_per_month.constant_value*@nb_qr.constant_value + wp_leaders_days_per_month.constant_value)*@remaining_time)
      montee                             = default_to_zero { SDPActivity.find_by_title('Montee en competences').remaining }
      souscharges                        = default_to_zero { SDPActivity.find_by_title('Sous charges').remaining }
      incidents                          = default_to_zero { SDPActivity.find_by_title('Incidents').remaining }
      init                               = default_to_zero { SDPActivity.find_by_title('Initialization').remaining }
      bmc_avv                            = default_to_zero { SDPActivity.find_by_title('AVV BMC and other').remaining }
      @remaining_management              = default_to_zero { SDPPhase.find_by_title('Bundle Management').remaining - (montee+souscharges+init+bmc_avv+incidents) }
      @ci_remaining                      = default_to_zero { SDPPhase.find_by_title('Continuous Improvement').remaining }
      @qa_remaining                      = default_to_zero { SDPPhase.find_by_title('Quality Assurance').remaining }
      @error                             = ""
      @sold                              = @operational_total
      @provisions_initial                = 0
      @provisions_remaining_should_be    = 0
      @provisions_remaining              = 0 # Project management provision + operational provisions  (10% of 2011)
      @provisions_diff                   = 0
      @risks_remaining                   = 0
      @risks_remaining_should_be         = 0
      provision_qa_ci                    = 0
      @provisions.each { |p|
        calculate_provision(p,@operational_total_2011, @operational_total_2012, @operational_total_2013, @operational_total_2014, @operational_total_2016, @operational_percent_total)
        @sold += p.initial_should_be if p.title != 'Operational Management' # as already counted in @operational_total
        if p.title == 'Operational Management' or p.title == 'Project Management'
          @provisions_initial             += p.initial
          @provisions_remaining_should_be += p.reevaluated_should_be
          @provisions_remaining           += p.reevaluated
          @provisions_diff                += p.difference
        elsif p.title == 'Continuous Improvement' or p.title == 'Quality Assurance'
          provision_qa_ci += p.reevaluated_should_be
        elsif p.title == 'Risks'
          @risks_remaining            = p.reevaluated
          @risks_remaining_should_be  = p.reevaluated_should_be
        end
        }
      @real_balance                 = @sdp_initial_balance - (@theorical_management - @remaining_management)
      @real_balance_and_provisions  = @real_balance + @provisions_remaining_should_be
      @not_included_remaining       = (@theorical_management-@remaining_management) + provision_qa_ci
      @other_provisions             = provision_qa_ci + @risks_remaining_should_be
      @total_provisions             = @other_provisions + @provisions_remaining_should_be
      sdp_graph
    rescue Exception => e
      render(:text=>"<b>Error:</b> <i>#{e.message}</i><br/>#{e.backtrace.split("\n").join("<br/>")}")
    end
  end
  

  def mp_sdp_index
    @projects = SDPTask.find(:all, :select=>"project_code").map { |t| [t.project_name, t.project_code] }.uniq.sort
    prepare_mp_index
  end
  
  def prepare_mp_index
    begin
      project_code = params['project_code']['project_code'] if params['project_code']
      if !project_code or project_code==''
        @phases   = SDPPhase.all
      else
        @phases   = SDPPhase.find(:all, :conditions=>"id=1")
      end
    rescue Exception => e
      render(:text=>"<b>Error:</b> <i>#{e.message}</i><br/>#{e.backtrace.split("\n").join("<br/>")}")
    end
  end
 
  def refresh_mp_index
    prepare_mp_index
    #render(:layout=>false)
    render(:text=>'todo')
  end

  def get_sdp_graph_series(method)
    serie   = []
    labels  = []
    #id > 766 = dps logs from January 2016.
    logs = SdpImportLog.find(:all, :conditions=>["id > 766"], :order=>"id")
    first = logs.first.created_at
    for l in logs
      serie << [l.created_at-first, l.send(method)]
      labels << l.created_at.to_date
    end
    min = serie.map{|p| p[1]}.min
    max = serie.map{|p| p[1]}.max  
    serie = serie.map{ |l| [l[0], l[1]]}
    [serie, min, max, labels]
  end  

  def sdp_graph
    chart = GoogleChart::LineChart.new('700x300', "Gain", true)
    serie1, min1, max1, labels1 = get_sdp_graph_series(:sdp_real_balance_and_provisions)
    serie2, min2, max2, labels2 = get_sdp_graph_series(:sdp_initial_balance)
    #serie3, min3, max3, labels3 = get_sdp_graph_series(:sdp_real_balance)
    serie4, min4, max4, labels4 = get_sdp_graph_series(:provisions)
    min = [min1,min2,min4].min
    max = [max1,max2,max4].max
    serie1 = serie1.map{ |l| [l[0], l[1]-min]}
    serie2 = serie2.map{ |l| [l[0], l[1]-min]}
    #serie3 = serie3.map{ |l| [l[0], l[1]-min]}
    serie4 = serie4.map{ |l| [l[0], l[1]-min]}
    chart.data "Total gain",        serie1, '0000ff'
    chart.data  "SDP balance",       serie2, 'AA0000'
    #chart.data "SDP real balance",  serie3, 'ff0000'
    chart.data "Provisions",        serie4, '00ff00'
    chart.axis :y, :range => [min,max], :font_size => 10, :alignment => :center
    #chart.axis :x, :labels => labels1, :font_size => 10, :alignment => :center
    #chart.shape_marker :circle, :color=>'3333ff', :data_set_index=>0, :data_point_index=>-1, :pixel_size=>7
    @sdp_graph = chart.to_url #({:chd=>"t:#{serie.join(',')}", :chds=>"#{min},#{max}"})    
  end
  
  def get_sdp_graph_series_history(method,date)
    serie   = []
    labels  = []
    logs = SdpImportLog.find(:all,:conditions => ['created_at <= ?',date+" 23:59:59"], :order=>"id")
    if logs!=nil and logs.first != nil
      first = logs.first.created_at
      for l in logs
        serie << [l.created_at-first, l.send(method)]
        labels << l.created_at.to_date
      end
      min = serie.map{|p| p[1]}.min
      max = serie.map{|p| p[1]}.max
      serie = serie.map{ |l| [l[0], l[1]]}
      [serie, min, max, labels, true]
    else
      [ 0.to_s, 0.to_s, 0.to_s, 0.to_s, false]
    end
  end  

  def sdp_graph_history
    render nil if params[:date]==nil
    chart = GoogleChart::LineChart.new('600x200', "Gain", true)
    serie1, min1, max1, labels1, result1 = get_sdp_graph_series_history(:sdp_real_balance_and_provisions,params[:date])
    serie2, min2, max2, labels2, result2 = get_sdp_graph_series_history(:sdp_initial_balance,params[:date])
    serie4, min4, max4, labels4, result3 = get_sdp_graph_series_history(:provisions,params[:date])
    if result1 and result2 and result3
      min = [min1,min2,min4].min
      max = [max1,max2,min4].max
      serie1 = serie1.map{ |l| [l[0], l[1]-min]}
      serie2 = serie2.map{ |l| [l[0], l[1]-min]}
      serie4 = serie4.map{ |l| [l[0], l[1]-min]}
      chart.data "Total gain",        serie1, '0000ff'
      chart.data "SDP balance",       serie2, 'AA0000'
      chart.data "Provisions",        serie4, '00ff00'
      chart.axis :y, :range => [min,max], :font_size => 10, :alignment => :center
      @sdp_graph_history = chart.to_url#({:chd=>"t:#{serie.join(',')}", :chds=>"#{min},#{max}"})
      @sdp_graph_history_error = false
    else
      @sdp_graph_history_error = true
    end
  end
  
  def default_to_zero(&block)
    begin
      yield block
    rescue
      return 0
    end
  end

  def history_comparison
    logs = SdpImportLog.find(:all, :limit=>2, :order=>"id desc")
    return if logs.size < 2
    now  = logs[0]
    last = logs[1]
    @sdp_initial_balance_diff         = now.sdp_initial_balance - last.sdp_initial_balance
    @real_balance_and_provisions_diff = now.sdp_real_balance_and_provisions - last.sdp_real_balance_and_provisions
    @theorical_diff                   = (now.sdp_real_balance - now.sdp_initial_balance) - (last.sdp_real_balance - last.sdp_initial_balance)
    @provisions_diff                  = now.provisions - last.provisions
    @remaining_time_diff              = now.remaining_time - last.remaining_time
    @operational_diff                 = now.operational_total_minus_om - last.operational_total_minus_om
    @not_included_remaining_diff      = now.not_included_remaining - last.not_included_remaining
    @sold_diff                        = now.sold - last.sold
  end

  def sdp_index
    @sdp_index_by_mail = false
    sdp_index_prepare
    history_comparison
  end

  def sdp_index_by_type_prepare
    return if SDPTask.count.zero?
    begin      
      typesSorted = APP_CONFIG['sdp_by_type_order'].split(',') # Get sorted list of type to show from conf file
      remainTypes = SDPPhaseByType.all(:select => "DISTINCT(request_type)", :conditions => ['request_type not in (?)',typesSorted]) # Get all types availables in SDPPhaseByType table which are not in conf file
      @allPhaseRequestTypes = typesSorted + remainTypes.map { |t| t.request_type } # Types sorted + Types not specified in conf file
      
      @phasesByType = SDPPhaseByType.find(:all)
      @phasesByType.each { |p|  p.gain_percent = (p.initial==0) ? 0 : (p.balancei/p.initial*100/0.1).round * 0.1 }
      
      tasks2010                          = SDPTask.find(:all, :conditions=>"iteration='2010'")
      tasks2011                          = SDPTask.find(:all, :conditions=>"iteration='2011'")
      tasks2012                          = SDPTask.find(:all, :conditions=>"iteration='2012'")
      tasks2013                          = SDPTask.find(:all, :conditions=>"iteration='2013'")
      tasks2014                          = SDPTask.find(:all, :conditions=>"iteration='2014'")
      tasks2016                          = SDPTask.find(:all, :conditions=>"iteration='2016'")
      op2010                             = tasks2010.inject(0) { |sum, t| t.initial+sum}
      op2011                             = tasks2011.inject(0) { |sum, t| t.initial+sum}
      op2012                             = tasks2012.inject(0) { |sum, t| t.initial+sum}
      op2013                             = tasks2013.inject(0) { |sum, t| t.initial+sum}
      op2014                             = tasks2014.inject(0) { |sum, t| t.initial+sum}
      op2016                             = tasks2016.inject(0) { |sum, t| t.initial+sum}
      @operational2011_10percent_by_type         = round_to_hour(op2011*0.11111111111)
      @operational2012_10percent_by_type         = round_to_hour(op2012*0.11111111111)
      @operational2013_10percent_by_type         = round_to_hour(op2013*0.11111111111)
      @operational2014_10percent_by_type         = round_to_hour(op2014*0.11111111111)
      @operational2016_10percent_by_type         = 0 # round_to_hour(op2016*0.02040816)
      @operational_percent_total_by_type         = @operational2011_10percent_by_type + @operational2012_10percent_by_type + @operational2013_10percent_by_type + @operational2014_10percent_by_type + @operational2016_10percent_by_type
      @operational_total_2011_by_type            = op2010 + op2011 + @operational2011_10percent_by_type
      @operational_total_2012_by_type            = op2012 + @operational2012_10percent_by_type
      @operational_total_2013_by_type            = op2013 + @operational2013_10percent_by_type
      @operational_total_2014_by_type            = op2014 + @operational2014_10percent_by_type
      @operational_total_2016_by_type            = op2016 + @operational2016_10percent_by_type
      @operational_total_by_type                 = @operational_total_2011_by_type + @operational_total_2012_by_type + @operational_total_2013_by_type + @operational_total_2014_by_type + @operational_total_2016_by_type 
    rescue Exception => e
      render(:text=>"<b>Error:</b> <i>#{e.message}</i><br/>#{e.backtrace.split("\n").join("<br/>")}")
    end
  end
  
  def sdp_index_by_type
    sdp_index_by_type_prepare
  end

  def sdp_yes_check
    @task_ids = SDPTask.find(:all, :conditions=>"initial > 0").collect{ |t| "'#{t.request_id}'" }.uniq
    @yes_but_no_task_requests = Request.find(:all, :conditions=>["sdp='yes' and (start_date IS NULL or start_date > ?) and sdpiteration!='2014' and sdpiteration!='2013-Y3' and sdpiteration!='2013' and sdpiteration!='2012' and sdpiteration!='2011-Y2' and sdpiteration!='2011' and sdpiteration!='2010' and request_id not in (#{@task_ids.join(',')})", Date.parse('2016-01-01')])
    @yes_but_cancelled_requests = Request.find(:all, :conditions=>["(start_date IS NULL or start_date > ?) and sdpiteration!='2014' and sdpiteration!='2013-Y3' and sdpiteration!='2013' and sdpiteration!='2012' and sdpiteration!='2011-Y2' and sdpiteration!='2011' and sdpiteration!='2010' and request_id in (#{@task_ids.join(',')}) and (status='cancelled' or status='removed')", Date.parse('2016-01-01')])
    @no_but_sdp = Request.find(:all, :conditions=>"request_id in (#{@task_ids.join(',')}) and sdp='no'")
  end

  def requests_ended_check
    reqs = Request.find(:all, :conditions=>"resolution='ended' or resolution='aborted'")
    @tasks = []
    reqs.each { |r|
      @tasks += SDPTask.find(:all, :conditions=>"request_id='#{r.request_id}' and remaining > 0")
      }
    ids = @tasks.collect {|t| t.request_id}.uniq.join(',')
    if ids == ""
      @requests = []
    else
      @requests = Request.find(:all, :conditions=>"request_id in (#{ids})")
    end
    @no_end_date = Request.find(:all, :conditions=>"(resolution='ended' or resolution='aborted') and end_date=''")
  end

  def requests_should_be_ended_check
    reqs = Request.find(:all, :conditions=>"status='assigned' and resolution!='ended' and resolution!='aborted'")
    @tasks = []
    reqs.each { |r|
      tmp = SDPTask.find(:all, :conditions=>"request_id='#{r.request_id}'")
      remaining = tmp.inject(0.0)  { |sum, t| sum+t.remaining}
      @tasks += tmp if remaining == 0
      }
    ids = @tasks.collect {|t| t.request_id}.uniq.join(',')
    if ids == ""
      @requests = []
    else
      @requests = Request.find(:all, :conditions=>"request_id in (#{ids})", :order=>"assigned_to")
    end
  end

  def workload_check
    @requests = Request.all
    @tasks = []
    @requests.each { |r|
      @tasks += SDPTask.find(:all, :conditions=>"request_id='#{r.request_id}' and remaining > 0")
      }
  end

  def kpi_check
    @physicalsWithoutSuite = Project.find(:all, :joins=>["JOIN requests ON requests.project_id = projects.id"], :conditions=>["is_running = 1 and suite_tag_id IS NULL and (requests.request_type = 'Yes' or requests.request_type = 'Suite') and name IS NOT NULL"], :group => "projects.id")
    @projectsWithoutSuiteForSpecificWPs = Project.find(:all, :joins=>["JOIN requests ON requests.project_id = projects.id"], :conditions=>["is_running = 1 and suite_tag_id IS NULL and requests.work_package IN (?) and name IS NOT NULL", APP_CONFIG['report_kpi_projects_should_have_suite_for_wp'].join(",")], :group => "projects.id")
    @specificWPs = APP_CONFIG['report_kpi_projects_should_have_suite_for_wp'].join(", ")
    @requestsWithoutMilestone = Request.find(:all, :conditions => ["work_package in (?) and milestone ='N/A'", APP_CONFIG['report_kpi_requests_should_have_milestone_for_wp'].join(",")])
    @specificWPsForRequests = APP_CONFIG['report_kpi_requests_should_have_milestone_for_wp'].join(", ")
  end

  def sdp_people
    tasks   = SDPTask.find(:all, :conditions=>"iteration!='HO' and iteration!='P'")
    @trig   = tasks.collect { |t| t.collab }.uniq
    @people = []
    @trig.each { |trig|
      tasks   = SDPTask.find(:all, :conditions=>"collab='#{trig}' and iteration!='HO' and iteration!='P'")
      initial = tasks.inject(0.0) { |sum, t| sum+t.assigned}
      balance = tasks.inject(0.0) { |sum, t| sum+t.balancea}
      if initial > 0
        percent   = ((balance / initial)*100 / 0.1).round * 0.1
        @people << [trig,initial, balance, percent]
      else
        @people << [trig,initial, balance, 0]
      end
      }
    @people = @people.sort_by { |p| [-p[3],-p[1]]}
  end

  def sdp_logs
    @people = Person.find(:all, :conditions=>"has_left=0 and is_supervisor=0", :order=>"name")
    @last_sdp_phase = SDPPhase.find(:first, :order=>'updated_at desc')
    if @last_sdp_phase != nil
      @last_sdp_update = @last_sdp_phase.updated_at
    else
      @last_sdp_update = nil
    end
  end

  def sdp_conso
    @people = Person.find(:all, :conditions=>"is_supervisor=0").select {|p| p.sdp_logs.last}.sort_by { |p| p.sdp_logs.last.percent }
    @init_total     = @people.map{|p| p.sdp_logs.last.initial}.inject(0) { |i, sum| sum+i}
    @balance        = @people.map{|p| p.sdp_logs.last.balance}.inject(0) { |i, sum| sum+i}
    @percent_total  = ((@balance / @init_total)*100 / 0.01).round * 0.01
  end

  def sdp_period
    @people = Person.find(:all, :conditions=>["has_left = ? and company_id = ? and is_supervisor = ? and is_transverse = ?", 0, 1, 0, 0], :order=>"name")
    @period_selected_start = @period_selected_stop = @gain = ""
    if params[:person_selected]
      @person_selected = params[:person_selected].to_i
      @period_selected_start = params[:period_selected_start].to_date
      @period_selected_stop = params[:period_selected_stop].to_date
      @gain = get_gain(@person_selected, @period_selected_start, @period_selected_stop)
    end
  end

  def get_gain(person, period_start, period_stop)
    gain = 0
    person = Person.find(:first, :conditions=>["id = ?", person])
    if person
      gain = person.sdp_percent_period(period_start, period_stop)
    end
    return gain
  end

  def sdp_add
    @requests = Request.find(:all, :conditions=>"sdp='No' and resolution='in progress' and status!='to be validated' and complexity!='TBD' and status!='cancelled'")
    @pbs      = Request.find(:all, :conditions=>"sdp='No' and resolution='in progress' and (status='to be validated' or status='cancelled' or status='removed')")
  end

  def load_errors
    # check if sdp loads are corrects
    @empty_sdp_iteration = Request.find(:all, :conditions=>"sdpiteration='' and status!='removed'", :order=>"request_id")
    # TODO: not portable
    @checks = Request.find(:all, :conditions=>["(start_date IS NULL or start_date > ?) and status!='removed' and sdp='Yes' and sdpiteration!='' and sdpiteration!='2014' and sdpiteration!='2013-Y3' and sdpiteration!='2013' and sdpiteration!='2012' and sdpiteration!='2011-Y2' and sdpiteration!='2011' and sdpiteration!='2010'", Date.parse('2016-01-01')], :order=>"request_id")
    @checks = @checks.select {|r|
      r.workload2.to_f != r.sdp_tasks_initial_sum
      }
  end

  def import_monthly_tasks
    @monthlyTasks = MonthlyTask.find(:all)
  end

  def requests_by_year
    @requests = Request.find(:all, :conditions=>"status='to be validated'", :order=>"workstream, summary, milestone")
    @years = [2011, 2012, 2013, 2014]
  end

  def projects_length
    @projects = Project.find(:all, :conditions=>["name IS NOT NULL"]).select { |p| p.projects.size==0}
    @results  = []
    for p in @projects
      m,l,pl = p.length
      if m[0]==m[1]
        mt = -1
      else
        mt = m.join('-')
      end
      if pl <= 0
        percent = 0.0
      else
        percent = (((l-pl).to_f / pl )*100).round
      end
      @results << [p.full_name, mt, l, pl, percent, p.id]
    end
    @results = @results.sort_by { |p| [-p[4], -p[3]]}
  end

  def rmt_date_check
    wp = "'WP1.1 - Quality Control', 'WP1.2 - Quality Assurance'"
    @requests = Request.find(:all, :conditions=>"status!='cancelled' and status!='removed' and resolution='ended' and work_package in (#{wp})")
  end

  def qr_per_ws
    @ws = Workstream.all
    @qr = Person.find(:all, :conditions=>"has_left=0 and is_transverse=0")
    @associations = Hash.new
    @ws.each { |ws|
      @qr.each { |qr|
        projects = qr.active_projects_by_workstream(ws.name)
        if projects.size > 0
          @associations[ws.name] ||= Hash.new
          @associations[ws.name][:ws_projects] ||= Project.active_projects_by_workstream(ws.name).size
          @associations[ws.name][:qr] ||= Array.new
          @associations[ws.name][:qr] << {:name=>qr.name, :projects=>projects}
          @associations[ws.name][:ws_id] = ws.id
        end
        next
        }
      }
  end

  def qr_per_ws_detail
    ws_id = params['id'].to_i
    @ws = Workstream.find(ws_id)
    @qr = Person.find(:all, :conditions=>"has_left=0 and is_transverse=0")
    @associations = Array.new
    @qr.each { |qr|
      projects = qr.active_projects_by_workstream(@ws.name)
      if projects.size > 0
        @associations << {:qr=>qr, :projects=>projects}
      end
      }
  end

  def last_projects
    filter = params[:filter]
    session["last_projects_filter"] = filter
    case filter
    when "m5"
      @projects = Project.find(:all, :conditions=>["name IS NOT NULL"], :order=>"created_at desc").select{|p| 
        m3 = p.find_milestone_by_name("M3")
        m5 = p.find_milestone_by_name("M5") || p.find_milestone_by_name("M5/M7")
        m5 and m5.done == 0 and (m5.active_requests.size > 0 or (m3 and m3.active_requests.size>0))
        }
    else
      @projects = Project.find(:all, :conditions=>["name IS NOT NULL"], :limit=>50, :order=>"created_at desc").select{|p| p.open_requests.size > 0}
    end
  end

  def next_milestones
    @next_milestones = (Milestone.find(:all) + Request.all).select{|m| m.date and m.date >= Date.today()-2.days and m.date <= Date.today()+2.months}.sort_by{|m| m.date ? m.date : Date.today()}
  end

  def project_list
    # verify session filter
    # TODO

    @projects = Project.find(:all, :conditions=>["name IS NOT NULL"]).select{ |p| p.has_requests }.sort_by { |p|
      u = p.get_status.updated_at
      if !u
        Time.parse("2000/01/01")
      else
        u
      end
      }.reverse
  end
  
  def check_sdp_remaining_workload
    @sdp_wrong_tasks = []
    sdp_tasks = SDPTask.all
    sdp_tasks.each_with_index do |sdp_task, index|
      rem_coef = sdp_task.remaining.modulo(0.125)
      if sdp_task.remaining > 0 and rem_coef > 0
          @sdp_wrong_tasks << sdp_task
      end
    end
  end
  
  def check_difference_po_milestone_date
    @invalid_requests = []
    Request.find(:all, :conditions=>"status='to be validated'").each do |request|
      @invalid_requests << request if !request.date or request.date.year.to_s != request.po.strip
    end
    @invalid_requests = @invalid_requests.sort_by { |r| [r.workstream, r.summary, (r.date ? r.date.to_s : ""), r.po] }
  end

  def export_database_index
  end
  
  def export_database
    dataPath = Rails.public_path + "/data"
    db_config = ActiveRecord::Base.configurations[RAILS_ENV]
    system("mysqldump -u#{db_config['username']} -p#{db_config['password']} -P 8889 -h localhost #{db_config['database']} > #{dataPath}/dump_bdd.sql")
    system("cd #{dataPath} && tar -zcvf #{dataPath}/dump_bdd.tar.gz dump_bdd.sql")
    send_file "#{dataPath}/dump_bdd.tar.gz"
  end
  
  def create_dump_database
     dataPath = Rails.public_path + "/data"
     db_config = ActiveRecord::Base.configurations[RAILS_ENV]
     system("mysqldump -u#{db_config['username']} -p#{db_config['password']} -P 8889 -h localhost #{db_config['database']} > #{dataPath}/dump_bdd.sql")
     system("cd #{dataPath} && tar -zcvf #{dataPath}/dump_bdd.tar.gz dump_bdd.sql")
     render :nothing => true
  end
  
  def download_dump_database
    scriptPath = RAILS_ROOT+"/script"
    dataPath = Rails.public_path + "/data"
    system('echo "rm #{dataPath}/dump_bdd.sql" | at now +3minute')
    system('echo "rm #{dataPath}/dump_bdd.tar.gz" | at now +3minute')
    send_file "#{dataPath}/dump_bdd.tar.gz"
  end
  
  def delete_bdd_dump_files
    dataPath = Rails.public_path + "/data"
    system("rm -f -r #{dataPath}/dump_bdd.sql && rm -f -r #{dataPath}/dump_bdd.tar.gz")
    render :nothing => true
  end
  
  def show_counter_history
    @stream_id        = params[:stream_id]
    @request_id       = params[:request_id]
    @filter = false
    if params[:filter]
      @filter = true
    end
    streams           = Stream.find(:all)
    @streams_array    = [["All",0]]
    streams.each{ |s| 
      @streams_array << [s.name, s.id]
    }
    requests          = Request.find(:all, :conditions=>["status != 'removed' and work_package like ? or work_package like ? or work_package like ? or work_package like ?", "%"+WORKPACKAGE_QS[0]+"%","%"+WORKPACKAGE_QS[1]+"%","%"+WORKPACKAGE_SPIDERS[0]+"%","%"+WORKPACKAGE_SPIDERS[1]+"%"], :order=>"request_id")
    @requests_array   = [] 
    requests.each{ |r| 
      @requests_array << [r.request_id.to_s+" "+r.summary, r.id ]
    }
    
    spider_condition  = "concerned_spider_id IS NOT NULL"
    qs_condition      = "concerned_status_id IS NOT NULL"
    if @stream_id and @stream_id != "0"
      spider_condition = spider_condition+" and history_counters.stream_id="+@stream_id.to_s
      qs_condition     = qs_condition+" and history_counters.stream_id="+@stream_id.to_s
    end
    if @request_id and @request_id != "0"
      spider_condition = spider_condition+" and history_counters.request_id="+@request_id.to_s
      qs_condition     = qs_condition+" and history_counters.request_id="+@request_id.to_s
    end
    spider_condition_vt = spider_condition + " and (concerned_spider_id BETWEEN 10000 and 30000)"
    spider_condition_vtt = spider_condition + " and concerned_spider_id > 30000"
    
    spider_counter = HistoryCounter.find(:all,:conditions=>[spider_condition],
                                          :joins => ["JOIN requests ON requests.id = history_counters.request_id",
                                          "JOIN spiders ON spiders.id = history_counters.concerned_spider_id",
                                          "JOIN projects ON projects.id = spiders.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"
                                          ],
                                          :order=>"requests.request_id ASC, parent.name ASC, projects.name ASC, history_counters.action_date ASC")
    
    spider_counter_vt = HistoryCounter.find(:all,:conditions=>[spider_condition_vt],
                                          :joins => ["JOIN requests ON requests.id = history_counters.request_id",
                                          "JOIN deviation_spiders ON deviation_spiders.id = history_counters.concerned_spider_id",
                                          "JOIN projects ON projects.id = deviation_spiders.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"
                                          ],
                                          :order=>"requests.request_id ASC, parent.name ASC, projects.name ASC, history_counters.action_date ASC")

    spider_counter_vtt = HistoryCounter.find(:all,:conditions=>[spider_condition_vtt],
                                          :joins => ["JOIN requests ON requests.id = history_counters.request_id",
                                          "JOIN svt_deviation_spiders ON svt_deviation_spiders.id = history_counters.concerned_spider_id",
                                          "JOIN projects ON projects.id = svt_deviation_spiders.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"
                                          ],
                                          :order=>"requests.request_id ASC, parent.name ASC, projects.name ASC, history_counters.action_date ASC")

    table_spider_counter_temp = Array.new
    @table_spider_counter = Array.new

    spider_counter.each do |counter|
      count_struct = Spider_counter_struct.new
      count_struct.historycounter = counter
      count_struct.spider_version = 1
      table_spider_counter_temp << count_struct
    end
    spider_counter_vt.each do |counter_vt|
      count_struct = Spider_counter_struct.new
      count_struct.historycounter = counter_vt
      count_struct.spider_version = 2
      table_spider_counter_temp << count_struct
    end
    spider_counter_vtt.each do |counter_vtt|
      count_struct = Spider_counter_struct.new
      count_struct.historycounter = counter_vtt
      count_struct.spider_version = 3
      table_spider_counter_temp << count_struct
    end

    @table_spider_counter = table_spider_counter_temp.sort_by { |tsc| [tsc.historycounter.request_id, tsc.historycounter.action_date]}

    @qs_counter     = HistoryCounter.find(:all,:conditions=>[qs_condition],
                                          :joins => ["JOIN requests ON requests.id = history_counters.request_id", 
                                          "JOIN statuses ON statuses.id = history_counters.concerned_status_id",
                                          "JOIN projects ON projects.id = statuses.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"],
                                          :order=>"requests.request_id ASC, parent.name ASC, projects.name ASC, history_counters.action_date ASC")
  end
  
  def show_counter_history_without_rmt
    @stream_id        = params[:stream_id]
    streams           = Stream.find(:all)
    @streams_array    = [["All",0]]
    streams.each{ |s| 
      @streams_array << [s.name, s.id]
    }

    spider_condition  = "concerned_spider_id IS NOT NULL and request_id IS NULL"
    qs_condition      = "concerned_status_id IS NOT NULL and request_id IS NULL"
    if @stream_id and @stream_id!= "0"
      spider_condition = spider_condition+" and history_counters.stream_id="+@stream_id.to_s
      qs_condition     = qs_condition+" and history_counters.stream_id="+@stream_id.to_s
    end
    spider_condition_vt = spider_condition + " and (concerned_spider_id BETWEEN 10000 and 30000)"
    spider_condition_vtt = spider_condition + " and concerned_spider_id > 30000"
      
    spider_counter = HistoryCounter.find(:all,:conditions=>[spider_condition],
                                          :joins => ["JOIN spiders ON spiders.id = history_counters.concerned_spider_id",
                                          "JOIN projects ON projects.id = spiders.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"
                                          ],
                                          :order=>"parent.name ASC, projects.name ASC")
    spider_counter_vt = HistoryCounter.find(:all,:conditions=>[spider_condition_vt],
                                          :joins => ["JOIN deviation_spiders ON deviation_spiders.id = history_counters.concerned_spider_id",
                                          "JOIN projects ON projects.id = deviation_spiders.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"
                                          ],
                                          :order=>"parent.name ASC, projects.name ASC")
    spider_counter_vtt = HistoryCounter.find(:all,:conditions=>[spider_condition_vtt],
                                          :joins => ["JOIN svt_deviation_spiders ON svt_deviation_spiders.id = history_counters.concerned_spider_id",
                                          "JOIN projects ON projects.id = svt_deviation_spiders.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"
                                          ],
                                          :order=>"parent.name ASC, projects.name ASC")

    tmp_qs_counter_no_request     = HistoryCounter.find(:all,:conditions=>[qs_condition],
                                          :joins => ["JOIN statuses ON statuses.id = history_counters.concerned_status_id",
                                          "JOIN projects ON projects.id = statuses.project_id",
                                          "JOIN projects as parent ON parent.id = projects.project_id"],
                                          :order=>"parent.name ASC, projects.name ASC")
    
    tmp_spider_counter_no_request = Array.new
    @spider_counter_no_request    = Array.new
    @qs_counter_no_request        = Array.new

    spider_counter.each do |counter|
      count_struct = Spider_counter_struct.new
      count_struct.historycounter = counter
      count_struct.spider_version = 1
      tmp_spider_counter_no_request << count_struct
    end
    spider_counter_vt.each do |counter_vt|
      count_struct = Spider_counter_struct.new
      count_struct.historycounter = counter_vt
      count_struct.spider_version = 2
      tmp_spider_counter_no_request << count_struct
    end
    spider_counter_vtt.each do |counter_vtt|
      count_struct = Spider_counter_struct.new
      count_struct.historycounter = counter_vtt
      count_struct.spider_version = 3
      tmp_spider_counter_no_request << count_struct
    end

    # For each spider counter
    tmp_spider_counter_no_request.each do |s_req|
      current_spider_history            = Hash.new
      current_spider_history["object"]  = s_req
      current_spider_history["request"] = nil
      current_spider_user               = Person.find(s_req.historycounter.author_id)
      
      # Check if we have a available spider request thanks to Workstream
      if s_req.spider_version == 1
        stream_found  = Stream.find_with_workstream(s_req.historycounter.spider.project.workstream)
      elsif s_req.spider_version == 2
        stream_found  = Stream.find_with_workstream(s_req.historycounter.deviation_spider.project.workstream)
      elsif s_req.spider_version == 3
        stream_found  = Stream.find_with_workstream(s_req.historycounter.svt_deviation_spider.project.workstream)
      end
      if ((stream_found) and (current_user.id.to_i == current_spider_user.id.to_i))
        request_found = stream_found.get_current_spider_counter_request(current_spider_user)
        if request_found
          current_spider_history["request"] = request_found
        end
      end
      @spider_counter_no_request << current_spider_history
    end

    # For each QS counter
    tmp_qs_counter_no_request.each do |qs_req|
      current_qs_history            = Hash.new
      current_qs_history["object"]  = qs_req
      current_qs_history["request"] = nil
      current_qs_user               = Person.find(qs_req.author_id)
      
      # Check if we have a available qs request thanks to Workstream 
      stream_found  = Stream.find_with_workstream(qs_req.status.project.workstream)
      if ((stream_found) and (current_user.id.to_i == current_qs_user.id.to_i))
        request_found = stream_found.get_current_qs_counter_request(current_qs_user)
        if request_found
          current_qs_history["request"] = request_found
        end
      end
      @qs_counter_no_request << current_qs_history
    end
  
  end

  def delete_history_spider
    stream_id        = params[:stream_id]
    request_id       = params[:request_id]
    caller           = params[:caller]

    project_object = nil

    # Get the id
    history_object_id = params[:id]

    # Get the object
    history_object = nil
    if (history_object_id)
      history_object = HistoryCounter.find(history_object_id)
    end

    # Delete the object
    if (history_object)

      if history_object.concerned_spider_id < 10000
        spider = history_object.spider
        if (history_object.spider and history_object.spider.project)
          project_object = history_object.spider.project
        end
      elsif history_object.concerned_spider_id > 10000 and history_object.concerned_spider_id < 30000
        spider = history_object.deviation_spider
        if (spider and spider.project)
          project_object = spider.project
        end
      elsif history_object.concerned_spider_id > 30000
        spider = history_object.svt_deviation_spider
        if (spider and spider.project)
          project_object = spider.project
        end
      end
        
      spider.impact_count = 0
      spider.save
      history_object.destroy
    end

    # Update spider counter or qs counter of project
    if (project_object)
      project_object.spider_count = project_object.spider_count - 1
      project_object.spider_count = 0 if (project_object.spider_count < 0)
      project_object.save
    end

    if caller == "show_counter_history"
      redirect_to :controller => 'tools', :action => 'show_counter_history', :stream_id => stream_id, :request_id => request_id
    else
      redirect_to :controller => 'tools', :action => 'show_counter_history_without_rmt', :stream_id => stream_id, :request_id => request_id
    end

  end

  def delete_history_qs
    stream_id        = params[:stream_id]
    request_id       = params[:request_id]
    caller           = params[:caller]

    project_object = nil

    # Get the id
    history_object_id = params[:id]

    # Get the object
    history_object = nil
    if (history_object_id)
      history_object = HistoryCounter.find(history_object_id)
    end

    # Delete the object
    if (history_object)
      if (history_object.status and history_object.status.project)
        project_object = history_object.status.project
      end
      history_object.destroy
    end

    # Update spider couter or qs counter of project
    if (project_object)
      project_object.qs_count = project_object.qs_count - 1
      project_object.qs_count = 0 if (project_object.qs_count < 0)
      project_object.save
    end

    if caller == "show_counter_history"
      redirect_to :controller => 'tools', :action => 'show_counter_history', :stream_id => stream_id, :request_id => request_id
    else
      redirect_to :controller => 'tools', :action => 'show_counter_history_without_rmt', :stream_id => stream_id, :request_id => request_id
    end

  end

  def circular_references
    @projects = Project.find(:all, :conditions=>["name IS NOT NULL"]).select {|p| p.has_circular_reference?}
  end

  def delete_parent
    project = Project.find(params[:id])
    project.project_id = nil
    project.save
    redirect_to('/tools/circular_references')
  end

  def show_stream_review_type
    @review_types = ReviewType.find(:all)
  end

  def update_stream_review_type_is_active
    review_type_id = params[:id]
    review_type_is_active = params[:is_active]
    review_type = ReviewType.find(:first,:conditions=>["id = ?", review_type_id])
    
    if (review_type != nil)
      review_type.is_active = review_type_is_active
      review_type.save
      render(:layout=>false, :text=>'updated') 
    else
      render(:layout=>false, :text=>'error') 
    end
  end

  def replace_e
    #Blatché
    CiProject.find(:all, :conditions=>["id=14 or id=15 or id=16 or id=17 or id=18 or id=19 or id=20 or id=21 or id=56"]).each do |ci|
      ci.sqli_validation_responsible = "Marion Blatché"
      ci.save
    end
    #Céline
    CiProject.find(:all, :conditions=>["id=43"]).each do |ci|
      ci.sqli_validation_responsible = "Céline Pages"
      ci.save
    end

    redirect_to '/tools/scripts'
  end

  def import_milestone_delays
    delay = MilestoneDelayRecord.new
    delay.project_id = 2097
    delay.updated_by = 92
    delay.milestone_id = 32664
    delay.planned_date = "2015-05-11"
    delay.current_date = "2015-05-19"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 10
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2476
    delay.updated_by = 42
    delay.milestone_id = 38351
    delay.planned_date = "2015-04-30"
    delay.current_date = "2015-05-18"
    delay.reason_first_id = 12
    delay.reason_second_id = 13
    delay.reason_third_id = 22
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2402
    delay.updated_by = 42
    delay.milestone_id = 38608
    delay.planned_date = "2015-06-10"
    delay.current_date = "2015-07-10"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 28
    delay.reason_other = "Subcontractor for develompent has to be found"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2332
    delay.updated_by = 54
    delay.milestone_id = 36953
    delay.planned_date = "2015-05-19"
    delay.current_date = "2015-05-29"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "RU7 M5 date dependancies"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1324
    delay.updated_by = 42
    delay.milestone_id = 21867
    delay.planned_date = "2015-02-26"
    delay.current_date = "2015-04-30"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 31
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1856
    delay.updated_by = 42
    delay.milestone_id = 40577
    delay.planned_date = "2015-04-30"
    delay.current_date = "2015-06-25"
    delay.reason_first_id = 12
    delay.reason_second_id = 13
    delay.reason_third_id = 19
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2324
    delay.updated_by = 42
    delay.milestone_id = 36841
    delay.planned_date = "2015-03-15"
    delay.current_date = "2015-06-15"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 30
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2446
    delay.updated_by = 91
    delay.milestone_id = 39084
    delay.planned_date = "2015-05-22"
    delay.current_date = "2015-05-29"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 10
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1998
    delay.updated_by = 84
    delay.milestone_id = 31596
    delay.planned_date = "2015-06-05"
    delay.current_date = "2015-06-30"
    delay.reason_first_id = 12
    delay.reason_second_id = 11
    delay.reason_third_id = 25
    delay.reason_other = "Same subcontractor is working on a related tool: Trackdev, which is the priority. If Trackdev is not ready on time, migration tool cannot be tested/used. To give more time for Trackdev development, Migration M9 has been postponed. Nevertheless, extra time was planned bt project team and there is no impact on global time and cost."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2363
    delay.updated_by = 84
    delay.milestone_id = 37663
    delay.planned_date = "2015-07-22"
    delay.current_date = "2015-09-30"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 31
    delay.reason_other = "BPL has an accident. BRD redaction and validation are delayed. M5 is postponed and will be merged with M7 (no global change on time and cost for now)."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2323
    delay.updated_by = 91
    delay.milestone_id = 37435
    delay.planned_date = "2015-04-01"
    delay.current_date = "2015-05-12"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 7
    delay.reason_other = "The customer feedback assessment and AS IS workshops takes more time."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2229
    delay.updated_by = 73
    delay.milestone_id = 35737
    delay.planned_date = "2015-05-19"
    delay.current_date = "2015-06-07"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "RU7 M5 date dependancies"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2008
    delay.updated_by = 88
    delay.milestone_id = 36844
    delay.planned_date = "2015-03-20"
    delay.current_date = "2015-06-08"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "Techical reasons: Kerberos issues, MG5 of A330_neo"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2022
    delay.updated_by = 88
    delay.milestone_id = 31975
    delay.planned_date = "2015-05-04"
    delay.current_date = "2015-06-10"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "Other project dependency. Module from ROOTS project not deployed under GISEH platform: so it can not be integrated in Fan Noise V4"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2453
    delay.updated_by = 88
    delay.milestone_id = 39271
    delay.planned_date = "2015-05-28"
    delay.current_date = "2015-06-11"
    delay.reason_first_id = 12
    delay.reason_second_id = 9
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2258
    delay.updated_by = 88
    delay.milestone_id = 37046
    delay.planned_date = "2015-05-28"
    delay.current_date = "2015-06-11"
    delay.reason_first_id = 12
    delay.reason_second_id = 9
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2256
    delay.updated_by = 88
    delay.milestone_id = 37028
    delay.planned_date = "2015-05-28"
    delay.current_date = "2015-06-11"
    delay.reason_first_id = 12
    delay.reason_second_id = 9 
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2462
    delay.updated_by = 92
    delay.milestone_id = 40385
    delay.planned_date = "2015-04-15"
    delay.current_date = "2015-05-29"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "PM did'nt prepare the M3 because the GO for this version was already done by parent project. Finally, after several solutions and way to do the project studied, the final scope need to be presented to the steering (only by mail)."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2460
    delay.updated_by = 88
    delay.milestone_id = 39465
    delay.planned_date = "2015-05-05"
    delay.current_date = "2015-05-28"
    delay.reason_first_id = 12
    delay.reason_second_id = 9
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2145
    delay.updated_by = 92
    delay.milestone_id = 40170
    delay.planned_date = "2015-04-30"
    delay.current_date = "2015-05-07"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "- Initial planning was done by the first PM and was nos applicable all along the project
    - Many many infra problems occured and was not predictable
    - PM planning are precise concerning the tasks to do but he do not plan the risk provision so the planning was many time postponned week by week"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2145
    delay.updated_by = 92
    delay.milestone_id = 34316
    delay.planned_date = "2015-05-07"
    delay.current_date = "2015-09-14"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "- Initial planning was done by the first PM and was nos applicable all along the project
    - Many many infra problems occured and was not predictable
    - PM planning are precise concerning the tasks to do but he do not plan the risk provision so the planning was many time postponned week by week"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2145
    delay.updated_by = 92
    delay.milestone_id = 34318
    delay.planned_date = "2015-05-15"
    delay.current_date = "2015-10-02"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "- Initial planning was done by the first PM and was nos applicable all along the project
    - Many many infra problems occured and was not predictable
    - PM planning are precise concerning the tasks to do but he do not plan the risk provision so the planning was many time postponned week by week"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2118
    delay.updated_by = 92
    delay.milestone_id = 33093
    delay.planned_date = "2015-03-27"
    delay.current_date = "2015-10-02"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "- Initial planning was done by the first PM and was nos applicable all along the project
    - Many many infra problems occured and was not predictable
    - PM planning are precise concerning the tasks to do but he do not plan the risk provision so the planning was many time postponned week by week"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2357
    delay.updated_by = 91
    delay.milestone_id = 37565
    delay.planned_date = "2015-09-25"
    delay.current_date = "2015-11-27"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 28
    delay.reason_other = "A330neo platform availability"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2035
    delay.updated_by = 92
    delay.milestone_id = 31738
    delay.planned_date = "2015-10-25"
    delay.current_date = "2015-07-06"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 7
    delay.reason_other = "Milestone many times postponed for many reasons since end 2014. The final delay is due to a release of the ressources of the project. The M13 will be done with the M14."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2035
    delay.updated_by = 92
    delay.milestone_id = 31739
    delay.planned_date = "2015-01-31"
    delay.current_date = "2015-07-06"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 7
    delay.reason_other = "Milestone many times postponed for many reasons since end 2014. The final delay is due to a release of the ressources of the project."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2422
    delay.updated_by = 42
    delay.milestone_id = 38638
    delay.planned_date = "2015-05-21"
    delay.current_date = "2015-05-28"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 29
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2029
    delay.updated_by = 88
    delay.milestone_id = 31905
    delay.planned_date = "2015-05-22"
    delay.current_date = "2015-06-22"
    delay.reason_first_id = 12
    delay.reason_second_id = 13
    delay.reason_third_id = 17
    delay.reason_other = "Loops on Architecture Dossier"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1422
    delay.updated_by = 84
    delay.milestone_id = 31914
    delay.planned_date = "2015-05-05"
    delay.current_date = "2015-05-27"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "EIS realised the 05/05/2015 but official mail sent the 27/05/2015"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2118
    delay.updated_by = 92
    delay.milestone_id = 33091
    delay.planned_date = "2015-06-12"
    delay.current_date = "2015-09-14"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "- Initial planning was done by the first PM and was nos applicable all along the project - Many many infra problems occured and was not predictable - PM planning are precise concerning the tasks to do but he do not plan the risk provision so the planning was many time postponned week by week"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2294
    delay.updated_by = 55
    delay.milestone_id = 39258
    delay.planned_date = "2015-04-27"
    delay.current_date = "2015-06-26"
    delay.reason_first_id = 12
    delay.reason_second_id = 13
    delay.reason_third_id = 17
    delay.reason_other = "INT Platform not available from India to deploy after each end of Sprint."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2176
    delay.updated_by = 88
    delay.milestone_id = 34714
    delay.planned_date = "2015-04-25"
    delay.current_date = "2015-07-20"
    delay.reason_first_id = 12
    delay.reason_second_id = 13
    delay.reason_third_id = 17
    delay.reason_other = "Deployment on GISEH platform has added lead time"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2412
    delay.updated_by = 92
    delay.milestone_id = 38693
    delay.planned_date = "2015-06-21"
    delay.current_date = "2015-07-31"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 15
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2412
    delay.updated_by = 92
    delay.milestone_id = 38695
    delay.planned_date = "2015-09-01"
    delay.current_date = "2015-09-30"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 15
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2199
    delay.updated_by = 91
    delay.milestone_id = 35190
    delay.planned_date = "2015-06-15"
    delay.current_date = "2015-06-29"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 28
    delay.reason_other = "Complete steering is not available for the 1st slot."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2362
    delay.updated_by = 91
    delay.milestone_id = 37644
    delay.planned_date = "2015-06-18"
    delay.current_date = "2015-06-30"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "Other solution identified during BRD finalization (M5 postponned to ananlyse and choose the best technical solution and involved an other supplier if needed)."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1981
    delay.updated_by = 65
    delay.milestone_id = 32446
    delay.planned_date = "2015-05-13"
    delay.current_date = "2015-06-23"
    delay.reason_first_id = 12
    delay.reason_second_id = 12
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1672
    delay.updated_by = 65
    delay.milestone_id = 27314
    delay.planned_date = "2015-03-05"
    delay.current_date = "2015-03-31"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 28
    delay.reason_other = "The shift is necessary in order to take benefit of a face to face discussion with the development team of this specific software feature from San Diego the 25th of March."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2325
    delay.updated_by = 65
    delay.milestone_id = 36869
    delay.planned_date = "2015-02-12"
    delay.current_date = "2015-02-18"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 29
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2360
    delay.updated_by = 65
    delay.milestone_id = 39895
    delay.planned_date = "2015-06-03"
    delay.current_date = "2015-07-30"
    delay.reason_first_id = 12
    delay.reason_second_id = 9
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2020
    delay.updated_by = 88
    delay.milestone_id = 31878
    delay.planned_date = "2015-03-02"
    delay.current_date = "2015-07-06"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "1st delay was due to alignment of schedule betwwen the 4 Work packages. 2nd delay is due to development activities that have taken more time than foreseen. For both delays, there is noimpact on EIS date"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2035
    delay.updated_by = 65
    delay.milestone_id = 31739
    delay.planned_date = "2015-07-06"
    delay.current_date = "2015-12-18"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "Two major reason, the lack of users feedbacks (6weeks between EIS and M14) and the redaction of users manuals that are late and will be done in July"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2498
    delay.updated_by = 84
    delay.milestone_id = 40374
    delay.planned_date = "24-06-2015"
    delay.current_date = "2015-07-17"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 28
    delay.reason_other = "It take more time than expected to have a validated ARD. Indeed, even if project was plan on ICT side, architects are really busy. Moreover, key people are busy and it is difficult to obtain key answers/validations."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2349
    delay.updated_by = 88
    delay.milestone_id = 38816
    delay.planned_date = "2015-06-16"
    delay.current_date = "2015-06-30"
    delay.reason_first_id = 12
    delay.reason_second_id = 11
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1884
    delay.updated_by = 92
    delay.milestone_id = 31177
    delay.planned_date = "2014-10-30"
    delay.current_date = "2015-11-16"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "Postponed many times since the original date (NOGO M3 2014-02-06, NOGO M5/M7 2014-11-27, technical issues and many project management issues."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2361
    delay.updated_by = 65
    delay.milestone_id = 40006
    delay.planned_date = "2015-04-20"
    delay.current_date = "2015-05-19"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 10
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2426
    delay.updated_by = 65
    delay.milestone_id = 38833
    delay.planned_date = "2015-06-15"
    delay.current_date = "2015-06-19"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 9
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2060
    delay.updated_by = 42
    delay.milestone_id = 32099
    delay.planned_date = "2015-03-15"
    delay.current_date = "2015-07-30"
    delay.reason_first_id = 12
    delay.reason_second_id = 13
    delay.reason_third_id = 19
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2192
    delay.updated_by = 85
    delay.milestone_id = 35081
    delay.planned_date = "2015-07-21"
    delay.current_date = "2015-09-01"
    delay.reason_first_id = 12
    delay.reason_second_id = 12
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2462
    delay.updated_by = 92
    delay.milestone_id = 39535
    delay.planned_date = "2015-06-29"
    delay.current_date = "2015-07-17"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "Ressources problems with the architect for ARD writting, lack of planning management (M3 NOGO), IN issue (infrastructure descibed in the ARD is no longer available), the project inherited issues not studied from previous versions and finally previous version of the ARD was completely obsolete, according to the Architect."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2461
    delay.updated_by = 73
    delay.milestone_id = 39490
    delay.planned_date = "2015-09-20"
    delay.current_date = "2016-01-20"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "After a first NOGO on G3/G4, project completely changes the solution of the project. It's now more complete (90% of Use Case, instead of 10% of UC) but costs and delay have been impacted."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2461
    delay.updated_by = 73
    delay.milestone_id = 39491
    delay.planned_date = "2015-12-15"
    delay.current_date = "2016-03-01"
    delay.reason_first_id = 9
    delay.reason_second_id = nil
    delay.reason_third_id = nil
    delay.reason_other = "After a first NOGO on G3/G4, project completely changes the solution of the project. It's now more complete (90% of Use Case, instead of 10% of UC) but costs and delay have been impacted."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2323
    delay.updated_by = 91
    delay.milestone_id = 37437
    delay.planned_date = "2015-08-07"
    delay.current_date = "2015-09-23"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 7
    delay.reason_other = "Workshops organization complicated to schedule in the initial short period."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2368
    delay.updated_by = 91
    delay.milestone_id = 37720
    delay.planned_date = "2015-12-17"
    delay.current_date = "2016-01-30"
    delay.reason_first_id = 11
    delay.reason_second_id = 7
    delay.reason_third_id = 8
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2118
    delay.updated_by = 92
    delay.milestone_id = 33094
    delay.planned_date = "2015-08-07"
    delay.current_date = "2015-10-26"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "- Initial planning was done by the first PM and was nos applicable all along the project - Many many infra problems occured and was not predictable - PM planning are precise concerning the tasks to do but he do not plan the risk provision so the planning was many time postponned week by week"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2145
    delay.updated_by = 92
    delay.milestone_id = 34319
    delay.planned_date = "2015-07-28"
    delay.current_date = "2015-10-26"
    delay.reason_first_id = 11
    delay.reason_second_id = 8
    delay.reason_third_id = 13
    delay.reason_other = "- Initial planning was done by the first PM and was nos applicable all along the project - Many many infra problems occured and was not predictable - PM planning are precise concerning the tasks to do but he do not plan the risk provision so the planning was many time postponned week by week"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2157
    delay.updated_by = 47
    delay.milestone_id = 34593
    delay.planned_date = "2015-08-28"
    delay.current_date = "2015-09-28"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 31
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2141
    delay.updated_by = 88
    delay.milestone_id = 34152
    delay.planned_date = "2015-03-26"
    delay.current_date = "2015-09-30"
    delay.reason_first_id = 12
    delay.reason_second_id = 12
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1768
    delay.updated_by = 91
    delay.milestone_id = 29100
    delay.planned_date = "2015-12-15"
    delay.current_date = "2016-01-05"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 28
    delay.reason_other = "PM in holidays during the initial milestone date and bank holidays period."
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2128
    delay.updated_by = 88
    delay.milestone_id = 33431
    delay.planned_date = "2015-07-01"
    delay.current_date = "2015-10-01"
    delay.reason_first_id = 12
    delay.reason_second_id = 11
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1954
    delay.updated_by = 88
    delay.milestone_id = 31118
    delay.planned_date = "2015-06-15"
    delay.current_date = "2015-07-17"
    delay.reason_first_id = 12
    delay.reason_second_id = 11
    delay.reason_third_id = 27
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2453
    delay.updated_by = 88
    delay.milestone_id = 39274
    delay.planned_date = "2015-09-04"
    delay.current_date = "2015-09-18"
    delay.reason_first_id = 12
    delay.reason_second_id = 11
    delay.reason_third_id = 25
    delay.reason_other = "Delay on development activity (may be due to bas understanding of need)"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 1938
    delay.updated_by = 72
    delay.milestone_id = 30657
    delay.planned_date = "2015-08-17"
    delay.current_date = "2015-09-15"
    delay.reason_first_id = 14
    delay.reason_second_id = 17
    delay.reason_third_id = 28
    delay.reason_other = "Business and IS teams in holidays"
    delay.delay_days = delay.get_delay_days
    delay.save

    delay = MilestoneDelayRecord.new
    delay.project_id = 2319
    delay.updated_by = 72
    delay.milestone_id = 37469
    delay.planned_date = "2015-08-28"
    delay.current_date = "2015-09-28"
    delay.reason_first_id = 12
    delay.reason_second_id = 12
    delay.reason_third_id = nil
    delay.reason_other = ""
    delay.delay_days = delay.get_delay_days
    delay.save

    redirect_to '/tools/scripts'
  end

  def add_workpackages_2016
    wp = Workpackage.new
    wp.title = "2016-WP1.1.1 - Quality Gate"
    wp.shortname = "2016 Quality Gate"
    wp.code = "2016-1.1.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.1.2 - Milestone - CCB review preparation"
    wp.shortname = "2016 Milestone - CCB review preparation"
    wp.code = "2016-1.1.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.1.3 - Process Adherence Measurement"
    wp.shortname = "2016 Process Adherence Measurement"
    wp.code = "2016-1.1.3"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.1.4 - Quality Status of a Project"
    wp.shortname = "2016 Quality status of a Project"
    wp.code = "2016-1.1.4"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.1.5 - Quality of Product Document"
    wp.shortname = "2016 Quality of Product Document"
    wp.code = "2016-1.1.5"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.1.6 - Quality of the Configuration Management"
    wp.shortname = "2016 Quality of the Configuration Management"
    wp.code = "2016-1.1.6"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.1.7 - Quality of the Code Static Review"
    wp.shortname = "2016 Quality of the Code Static Review"
    wp.code = "2016-1.1.7"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.1.8 - Quality of the Test Dossier"
    wp.shortname = "2016 Quality of the Test Dossier"
    wp.code = "2016-1.1.8"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.2.1 - Quality Assurance M3-M5 - G2-G5 - sM3-sM5"
    wp.shortname = "2016 Quality Assurance M3-M5"
    wp.code = "2016-1.2.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.2.2 - Quality Assurance M5-M10 - G5-G6"
    wp.shortname = "2016 Quality Assurance M5-M10"
    wp.code = "2016-1.2.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.2.3 - Quality Assurance Post M10 - Post G6"
    wp.shortname = "2016 Quality Assurance Post M10"
    wp.code = "2016-1.2.3"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.2.4 - Quality Assurance Agile Sprint 0"
    wp.shortname = "2016 Quality Assurance Agile Sprint 0"
    wp.code = "2016-1.2.4"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.2.5 - Quality Assurance Agile Sprints"
    wp.shortname = "2016 Quality Assurance Agile Sprints"
    wp.code = "2016-1.2.5"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.3.1 - DW-PLM Quality Plan"
    wp.shortname = "2016 DW-PLM Quality Plan"
    wp.code = "2016-1.3.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.3.2 - Support KPI and Reporting"
    wp.shortname = "2016 Support, KPI and Reporting"
    wp.code = "2016-1.3.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.3.3 - PSU (GPP LBIP Suite)"
    wp.shortname = "2016 PSU"
    wp.code = "2016-1.3.3"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.3.4 - LL"
    wp.shortname = "2016 LL"
    wp.code = "2016-1.3.4"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP1.3.5 - E-M&T Referential Change Management"
    wp.shortname = "2016 E-M&T Referential Change Management"
    wp.code = "2016-1.3.5"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP2.1 - Business Process Layout"
    wp.shortname = "2016 Business Process Layout"
    wp.code = "2016-2.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP2.2 - Functional Layout (Use Cases)"
    wp.shortname = "2016 Functional Layout"
    wp.code = "2016-2.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP2.3 - Information Layout (Data Model)"
    wp.shortname = "2016 Information Layout"
    wp.code = "2016-2.3"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP2.4 - Modeling Update"
    wp.shortname = "2016 Modeling Update"
    wp.code = "2016-2.4"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP3.1.1 - Root Cause Analysis (Classic Approach)"
    wp.shortname = "2016 Root Cause Analysis Classic"
    wp.code = "2016-3.1.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP3.1.2 - Root Cause Analysis (Seminar Approach)"
    wp.shortname = "2016 Root Cause Analysis Seminar"
    wp.code = "2016-3.1.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP3.2 - Action Plan of the Root Cause Analysis"
    wp.shortname = "2016 Action Plan of the Root Cause Analysis"
    wp.code = "2016-3.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.1 - Coaching Project Plan"
    wp.shortname = "2016 Coaching Project Plan"
    wp.code = "2016-4.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.2 - Coaching BRD"
    wp.shortname = "2016 Coaching BRD"
    wp.code = "2016-4.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.3 - Coaching V&V"
    wp.shortname = "2016 Coaching V&V"
    wp.code = "2016-4.3"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.4 - Coaching CMP"
    wp.shortname = "2016 Coaching CMP"
    wp.code = "2016-4.4"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.5 - Coaching HLR"
    wp.shortname = "2016 Coaching HLR"
    wp.code = "2016-4.5"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.6 - Coaching Use Case"
    wp.shortname = "2016 Coaching Use Case"
    wp.code = "2016-4.6"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.7.1 - Diagnosis and Project Launch"
    wp.shortname = "2016 Diagnosis and Project Launch"
    wp.code = "2016-4.7.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.7.2 - Sprint 0 Support"
    wp.shortname = "2016 Sprint 0 Support"
    wp.code = "2016-4.7.2"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.7.3 - Sprint Coaching"
    wp.shortname = "2016 Sprint Coaching"
    wp.code = "2016-4.7.3"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.8 - Risk Management"
    wp.shortname = "2016 Risk Management"
    wp.code = "2016-4.8"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP4.9 - E-M&T Referential"
    wp.shortname = "2016 E-M&T Referential"
    wp.code = "2016-4.9"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP5.1 - Light Expertise"
    wp.shortname = "2016 Light Expertise"
    wp.code = "2016-5.1"
    wp.save

    wp = Workpackage.new
    wp.title = "2016-WP5.2 - Complete Expertise"
    wp.shortname = "2016 Complete Expertise"
    wp.code = "2016-5.2"
    wp.save

    redirect_to '/tools/scripts'
  end

  def add_counter_value_2016
    cbv = CounterBaseValue.new
    cbv.complexity = "Easy"
    cbv.sdp_iteration = "2016"
    cbv.workpackage = "2016-WP1.1.4 - Quality Status of a Project"
    cbv.value = 10
    cbv.save

    cbv = CounterBaseValue.new
    cbv.complexity = "Medium"
    cbv.sdp_iteration = "2016"
    cbv.workpackage = "2016-WP1.1.4 - Quality Status of a Project"
    cbv.value = 50
    cbv.save

    cbv = CounterBaseValue.new
    cbv.complexity = "Easy"
    cbv.sdp_iteration = "2016"
    cbv.workpackage = "2016-WP1.1.3 - Process Adherence Measurement"
    cbv.value = 10
    cbv.save

    cbv = CounterBaseValue.new
    cbv.complexity = "Medium"
    cbv.sdp_iteration = "2016"
    cbv.workpackage = "2016-WP1.1.3 - Process Adherence Measurement"
    cbv.value = 50
    cbv.save

    redirect_to '/tools/scripts'
  end

  def delete_temp_deviation
    SvtDeviationSpiderConsolidationTemp.find(:all).each do |conso_temp|
      conso_temp.delete
    end

    redirect_to '/tools/scripts'
  end

  def script_check_svt_spiders_interfaces
    spiders_removed = Array.new
    @spiders_removed = Array.new
    @number_of_spider_removed = 0
    @consos_freelance = Array.new

    SvtDeviationSpiderConsolidation.find(:all).each do |conso|
      spider = nil
      spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", conso.svt_deviation_spider_id])
      if !spider
        spiders_removed << conso.svt_deviation_spider_id
        @consos_freelance << conso
      end
    end

    @spiders_removed = spiders_removed.uniq
    @number_of_spiders_removed = @spiders_removed.count
  end

  def clean_up_lost_svt_spiders
    SvtDeviationSpiderConsolidation.find(:all).each do |conso|
      spider = nil
      spider = SvtDeviationSpider.find(:first, :conditions=>["id = ?", conso.svt_deviation_spider_id])
      if !spider
        conso.delete
      end
    end

    redirect_to '/tools/script_check_svt_spiders_interfaces'
  end

  def milestone_delay_config
    @reason_one_selected = @reason_two_selected = nil

    if params[:add]
      milestone_delay_add_reason(params[:select_reason_one], params[:select_reason_two], params[:select_reason_three], params[:reason_one], params[:reason_two], params[:reason_three])
      milestone_delay_reasons_init
    elsif params[:remove]
      milestone_delay_remove_reason(params[:select_reason_one], params[:select_reason_two], params[:select_reason_three])
      milestone_delay_reasons_init
    else
      milestone_delay_reasons_init
    end

    if params[:reason_one_id] and !params[:reason_two_id]
      @reason_twos = milestone_delay_get_reason_twos(params[:reason_one_id])
      @reason_one_selected = MilestoneDelayReasonOne.find(:first, :conditions=>["id = ?", params[:reason_one_id]]).id
      @area_disabled_two = false
    elsif params[:reason_one_id] and params[:reason_two_id]
      @reason_twos = milestone_delay_get_reason_twos(params[:reason_one_id])
      @reason_threes = milestone_delay_get_reason_threes(params[:reason_two_id])
      @reason_one_selected = MilestoneDelayReasonOne.find(:first, :conditions=>["id = ?", params[:reason_one_id]]).id
      @reason_two_selected = MilestoneDelayReasonTwo.find(:first, :conditions=>["id = ?", params[:reason_two_id]]).id
      @area_disabled_two = false
      @area_disabled_three = false
    end

  end

  def milestone_delay_reasons_init
    @reason_ones = MilestoneDelayReasonOne.find(:all, :conditions=>["is_active = ?", true])
    @reason_twos = Array.new
    @reason_threes = Array.new

    @area_disabled_two = true
    @area_disabled_three = true
  end

  def milestone_delay_get_reason_twos(reason_one_id)
    reason_twos = Array.new
    reason_twos = MilestoneDelayReasonTwo.find(:all, :conditions=>["reason_one_id = ? and is_active = ?",reason_one_id, true])
    return reason_twos
  end

  def milestone_delay_get_reason_threes(reason_two_id)
    reason_threes = Array.new
    reason_threes = MilestoneDelayReasonThree.find(:all, :conditions=>["reason_two_id = ? and is_active = ?",reason_two_id, true])
    return reason_threes
  end

  def milestone_delay_add_reason(select_reason_one, select_reason_two, select_reason_three, reason_one, reason_two, reason_three)
    if reason_one != ""
      #add a lvl1 reason to the DB
      reason_one_to_add = MilestoneDelayReasonOne.new
      reason_one_to_add.reason_description = reason_one
      reason_one_to_add.is_active = true
      reason_one_to_add.save
    elsif select_reason_one != "" and reason_two != ""
      #add a lvl2 reason to the DB
      reason_two_to_add = MilestoneDelayReasonTwo.new
      reason_two_to_add.reason_description = reason_two
      reason_two_to_add.reason_one_id = select_reason_one
      reason_two_to_add.is_active = true
      reason_two_to_add.save
    elsif select_reason_one != "" and select_reason_two != "" and reason_three != ""
      #add a lvl3 reason to the DB
      reason_three_to_add = MilestoneDelayReasonThree.new
      reason_three_to_add.reason_description = reason_three
      reason_three_to_add.reason_two_id = select_reason_two
      reason_three_to_add.is_active = true
      reason_three_to_add.save
    end
  end

  def milestone_delay_remove_reason(reason_one, reason_two, reason_three)
    if reason_one != "" and reason_two != "" and reason_three != ""
      MilestoneDelayReasonThree.find(:first, :conditions=>["id = ?", reason_three]).delete
    elsif reason_one != "" and reason_two != "" and reason_three == ""
      milestone_reason_two = MilestoneDelayReasonTwo.find(:first, :conditions=>["id = ?", reason_two])
      MilestoneDelayReasonThree.find(:all, :conditions=>["reason_two_id = ?", milestone_reason_two.id]).each do |reason_three_to_delete|
        reason_three_to_delete.delete
      end
      milestone_reason_two.delete
    elsif reason_one != "" and reason_two == "" and reason_three == ""
      milestone_reason_one = MilestoneDelayReasonOne.find(:first, :conditions=>["id = ?", reason_one])
      MilestoneDelayReasonTwo.find(:all, :conditions=>["reason_one_id = ?", milestone_reason_one.id]).each do |reason_two_to_delete|
        MilestoneDelayReasonThree.find(:all, :conditions=>["reason_two_id = ?", reason_two_to_delete.id]).each do |reason_three_to_delete|
          reason_three_to_delete.delete
        end
        reason_two_to_delete.delete
      end
      milestone_reason_one.delete
    end
  end

  # --------
  # EXPORT
  # --------
  def export_delays_excel
    delay_from = params[:delay_from].to_s
    delay_to = params[:delay_to].to_s
    request = ""

    if delay_from != "" and delay_to == ""
      request = "planned_date >= '" + delay_from + "'"
    elsif delay_from == "" and delay_to != ""
      request = "planned_date <= '" + delay_to + "'"
    elsif delay_from != "" and delay_to != ""
      request = "planned_date between '" + delay_from + "' and '" + delay_to + "'"
    end

    @delays = Array.new
    MilestoneDelayRecord.find(:all, :conditions=>[request]).each do |delay|
      if delay.project and delay.project.id != 2480
        @delays << delay
      end
    end

    if @delays.count > 0
        begin
          @xml = Builder::XmlMarkup.new(:indent => 1)

          headers['Content-Type']         = "application/vnd.ms-excel"
          headers['Content-Disposition']  = 'attachment; filename="Delay Classification.xls"'
          headers['Cache-Control']        = ''
          render "delays.erb", :layout=>false
        rescue Exception => e
          render(:text=>"<b>#{e}</b><br>#{e.backtrace.join("<br>")}")
        end
    end
  end

  def manage_project_version
    @list_choices = ['', '1', '2', '3']
    @list_choices_index = [0, 1, 2, 3]
  end

  def set_project_version
    project_id = params[:project_id]
    version_chosen = params[:version_chosen].to_i
    result = 'false'

    if version_chosen != 0 and project_id != ""
      project = Project.find(:first, :conditions=>["id = ?", project_id])

      if project
        case version_chosen
        when 1
          project.deviation_spider = false
          project.deviation_spider_svt = false
        when 2
          project.deviation_spider = true
          project.deviation_spider_svt = false
        when 3
          project.deviation_spider = false
          project.deviation_spider_svt = true
        end
        project.save
        result = 'true'
      end
    elsif version_chosen == 0
      result = 'wrong_version'
    elsif project_id == ""
      result = 'wrong_project_id'
    end
    redirect_to('/tools/manage_project_version?result='+result)
  end

private

  def round_to_hour(f)
    (f/0.125).round * 0.125
  end

  def calculate_provision(p, total2011, total2012, total2013, total2014, total2016, operational_percent)
    pm_provision_adjustment  = SdpConstant.find(:first, :conditions=>["constant_name = ?", "PM_PROVISION_ADJUSTMENT"])
    qa_provision_adjustment  = SdpConstant.find(:first, :conditions=>["constant_name = ?", "QA_PROVISION_ADJUSTMENT"])
    rk_provision_adjustment  = SdpConstant.find(:first, :conditions=>["constant_name = ?", "RK_PROVISION_ADJUSTMENT"])
    ci_provision_adjustment  = SdpConstant.find(:first, :conditions=>["constant_name = ?", "CI_PROVISION_ADJUSTMENT"])
    op_provision_adjustment  = SdpConstant.find(:first, :conditions=>["constant_name = ?", "OP_PROVISION_ADJUSTMENT"])


    factor = 1.25 # 20% of PM (reciprocal)
    case p.title
      when 'Project Management'
        p.difference = round_to_hour(total2011*factor*0.09) + round_to_hour(total2012*factor*0.12) + round_to_hour(total2013*factor*0.12) + round_to_hour(total2014*factor*0.12) + round_to_hour(total2016*factor*0.08) - p.initial + pm_provision_adjustment.constant_value
      when 'Risks'
        p.difference = round_to_hour(total2011*factor*0.04) + round_to_hour(total2012*factor*0.02) + round_to_hour(total2013*factor*0.02) + round_to_hour(total2014*factor*0.02) + round_to_hour(total2016*factor*0.01) - p.initial + rk_provision_adjustment.constant_value
      when 'Operational Management'
        p.difference = operational_percent + round_to_hour(total2016*factor*0.09) - p.initial + op_provision_adjustment.constant_value
      when '(OLD) Quality Assurance'
        p.difference = 0
      when 'Quality Assurance'
        p.difference = round_to_hour(total2011*factor*0.02) + round_to_hour(total2012*factor*0.01) + round_to_hour(total2013*factor*0.01) + round_to_hour(total2014*factor*0.01) + round_to_hour(total2016*factor*0.01) - p.initial+ qa_provision_adjustment.constant_value
      when 'Continuous Improvement'
        p.difference = round_to_hour((total2011+total2012+total2013+total2014)*factor*0.05) + round_to_hour(total2016*factor*0.03) - p.initial  + ci_provision_adjustment.constant_value
      else
        p.difference = 0
    end
    p.initial_should_be     = p.initial     + p.difference
    p.reevaluated_should_be = p.reevaluated + p.difference
  end

  
  # Used to manage old data for the management of lifecycle of projects as object in model
  def convert_project_lifecycle_text_to_id
  end
end