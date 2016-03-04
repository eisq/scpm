class MilestonesController < ApplicationController

  before_filter :require_login

  # def index
  #  @milestones = Milestone.find(:all, :order=>"done, id")
  # end

  def new
    @milestone = Milestone.new(:project_id=>params[:project_id], :milestone_date=>Date.today(), :name=>'m3')
    get_infos
  end

  def create
    @milestone = Milestone.new(params[:milestone])
    if not @milestone.save
      render :action => 'new', :project_id=>params[:milestone][:project_id]
      return
    end
    redirect_to("/projects/show/#{@milestone.project_id}")
  end

  def edit
    id = params[:id]
    @milestone = Milestone.find(id)
    @quality_status = @milestone.project.get_quality_status
    @quality_status_color = @quality_status
    if @quality_status_color == "Amber"
      @quality_status_color = "Orange"
    end

    @date_error = params[:date_error]
    params[:date_error] ? @date_error = params[:date_error] : @date_error = 0

    get_infos
  end

  def milestone_delay_reasons_init
    @reason_ones = MilestoneDelayReasonOne.find(:all, :conditions=>["is_active = ?", true])
    @reason_twos = Array.new
    @reason_threes = Array.new
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

  def isDateSuperior(currentDateStr, nextDate)
    if currentDateStr and currentDateStr != ""
      begin
        if Date.parse(currentDateStr) > nextDate
          return true
        end
      rescue ArgumentError
        return false
      end
    end
    return false
  end

  def isDateInferior(currentDateStr, previousDate)
    if currentDateStr and currentDateStr != ""
      begin
        if Date.parse(currentDateStr) < previousDate
          return true
        end
      rescue ArgumentError
        return false
      end
    end
    return false
  end

  def update
    m   = Milestone.find(params[:id])
    old = m.done
    error = delay_days = 0
    old_date_bdd = new_date_bdd = nil
    delay_to_record = false

    # Try to update the date, if wrong format = remote
    if params[:milestone][:milestone_date] and params[:milestone][:milestone_date].length > 0
      begin
        date_bdd = Date.parse(params[:milestone][:milestone_date]).strftime("%Y-%m-%d %H:%M:%S")
        if date_bdd
          m.milestone_date = date_bdd
        else
          raise 'Date format error'
        end
      rescue ArgumentError
        error = 2
      end
    else
      m.milestone_date = nil
    end

    if params[:milestone][:actual_milestone_date] and params[:milestone][:actual_milestone_date].length > 0
      begin
        date_bdd = Date.parse(params[:milestone][:actual_milestone_date]).strftime("%Y-%m-%d %H:%M:%S")
        if date_bdd
          old_date_bdd = m.actual_milestone_date
          new_date_bdd = Date.parse(date_bdd).strftime("%Y-%m-%d %H:%M:%S")
          if old_date_bdd == nil or old_date_bdd == ""
            if m.milestone_date
              old_date_bdd = m.milestone_date
            else
              old_date_bdd = Date.parse(params[:milestone][:milestone_date]).strftime("%Y-%m-%d %H:%M:%S")
            end
          end
          delay_days =  get_date_from_bdd_date(new_date_bdd) - get_date_from_bdd_date(old_date_bdd)
          m.actual_milestone_date = date_bdd

          if delay_days > 0
            delay_to_record = true
          end
        else
          raise 'Date format error'
        end
      rescue ArgumentError
        error = 2
      end
    else
      m.actual_milestone_date = nil
    end

    #check if the milestone is done, is the current quality status selected
    if ((params[:milestone][:done].to_i == 1) and (params[:milestone][:current_quality_status].to_s == "Unknown"))
      error = 3
    end

    # If no date error
    if error == 0

      if params[:milestone][:name]
        m.name = params[:milestone][:name]
      end

      if params[:milestone][:comments]
        m.comments = params[:milestone][:comments]
      end

      if params[:milestone][:status]
        m.status = params[:milestone][:status]
      end

      if params[:milestone][:done]
        m.done = params[:milestone][:done]
      end

      if params[:milestone][:checklist_not_applicable]
        m.checklist_not_applicable = params[:milestone][:checklist_not_applicable]
      end

      if params[:milestone][:current_quality_status]
        m.current_quality_status = params[:milestone][:current_quality_status]
      end

      # Save
      m.save true

      if delay_to_record
        old_date_bdd = get_date_from_bdd_date(old_date_bdd)
        new_date_bdd = get_date_from_bdd_date(new_date_bdd)
        redirect_to :action=>:delay, :milestone_id=>m.id, :planned_date=>old_date_bdd, :current_date=>new_date_bdd, :delay_days=>delay_days
      else
        redirect_to "/projects/show/#{m.project_id}"
      end
    else
      redirect_to("/milestones/edit?id=#{params[:id]}&date_error="+error.to_s)
    end
  end

  def get_date_from_bdd_date(bdd_date)
    date_split = bdd_date.to_s.split("-")
    date = Date.new(date_split[0].to_i, date_split[1].to_i, date_split[2].to_i)

    return date
  end

  def delay
    @milestone_id = params[:milestone_id]
    project_id = Milestone.find(:first, :conditions=>["id = ?", @milestone_id]).project_id
    @planned_date = params[:planned_date]
    @current_date = params[:current_date]
    @delay_days = params[:delay_days]
    @reason_other = params[:reason_other]

    @reason_one_selected = @reason_two_selected = nil

    milestone_delay_reasons_init
    if params[:select_reason_one] and params[:select_reason_one] != "" and (!params[:select_reason_two] or params[:select_reason_two] == "")
      @reason_one_selected = MilestoneDelayReasonOne.find(:first, :conditions=>["id = ?", params[:select_reason_one]])
      if @reason_one_selected.reason_description == "Other reason"
      else
        @reason_twos = milestone_delay_get_reason_twos(params[:select_reason_one])
      end
      @reason_one_selected = @reason_one_selected.id
    elsif params[:select_reason_one] and params[:select_reason_one] != "" and params[:select_reason_two] and params[:select_reason_two] != 0
      @reason_one_selected = MilestoneDelayReasonOne.find(:first, :conditions=>["id = ?", params[:select_reason_one]]).id
      @reason_two_selected = MilestoneDelayReasonTwo.find(:first, :conditions=>["id = ?", params[:select_reason_two]])
      @reason_twos = milestone_delay_get_reason_twos(params[:select_reason_one])
      if @reason_two_selected.reason_description == "Other reason"
      else
        @reason_threes = milestone_delay_get_reason_threes(params[:select_reason_two])
      end
      @reason_two_selected = @reason_two_selected.id
    end
  end

  def add_delay_record
    if ((params[:select_reason_one] != "") or (params[:reason_other] != ""))
      project_id = Milestone.find(:first, :conditions=>["id = ?", params[:milestone_id]]).project_id
      milestone_delay = MilestoneDelayRecord.new
      milestone_delay.milestone_id = params[:milestone_id]
      milestone_delay.planned_date = params[:planned_date]
      milestone_delay.current_date = params[:current_date]
      milestone_delay.delay_days = params[:delay_days]
      milestone_delay.reason_first_id = params[:select_reason_one]
      milestone_delay.reason_second_id = params[:select_reason_two]
      milestone_delay.reason_third_id = params[:select_reason_three]
      milestone_delay.reason_other = params[:reason_other]
      milestone_delay.updated_by = current_user.id
      milestone_delay.project_id = project_id
      milestone_delay.save

      redirect_to "/projects/show/#{project_id}"
    else
      #error
      redirect_to "/milestones/delay?milestone_id=#{params[:milestone_id]}&planned_date=#{params[:planned_date]}&current_date=#{params[:current_date]}&delay_days=#{params[:delay_days]}&error=1"
    end
  end

  def destroy
    Milestone.find(params[:id].to_i).destroy
    render(:nothing=>true)
  end

  def set_checklist_not_applicable
    id = params[:id]
    m = Milestone.find(id)
    m.update_attribute('checklist_not_applicable',1)
    m.destroy_checklist
    render(:nothing=>true)
  end

  def set_checklist_applicable
    id = params[:id]
    m = Milestone.find(id)
    m.update_attribute('checklist_not_applicable',0)
    m.deploy_checklists
    render(:nothing=>true)
  end

  def deploy_checklists
    id = params[:id]
    Milestone.find(id).deploy_checklists
    render(:nothing=>true)
  end

  def ajax_milestone
    @project = Project.find(params[:project_id])
    render(:partial=>'milestones/milestone', :collection=>@project.sorted_milestones, :locals=>{:editable=> true})
  end

private

  def get_infos
    @projects = Project.find(:all, :conditions=>["name is not null"])
    @projects_select = @projects.map {|u| [u.workstream + " " + u.full_name,u.id]}.sort_by { |n| n[0]}
  end

end
