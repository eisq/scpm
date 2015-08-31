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

    @date_error = params[:date_error]
    params[:date_error] ? @date_error = params[:date_error] : @date_error = 0

    @reason_one_selected = @reason_two_selected = nil
    @other_disabled = true

    milestone_delay_reasons_init
    if params[:reason_one_id] and !params[:reason_two_id]
      @reason_one_selected = MilestoneDelayReasonOne.find(:first, :conditions=>["id = ?", params[:reason_one_id]])
      if @reason_one_selected.reason_description == "Other reason"
        @other_disabled = false
      else
        @reason_twos = milestone_delay_get_reason_twos(params[:reason_one_id])
      end
      @reason_one_selected = @reason_one_selected.id
    elsif params[:reason_one_id] and params[:reason_two_id]
      @reason_one_selected = MilestoneDelayReasonOne.find(:first, :conditions=>["id = ?", params[:reason_one_id]]).id
      @reason_two_selected = MilestoneDelayReasonTwo.find(:first, :conditions=>["id = ?", params[:reason_two_id]])
      @reason_twos = milestone_delay_get_reason_twos(params[:reason_one_id])
      if @reason_two_selected.reason_description == "Other reason"
        @other_disabled = false
      else
        @reason_threes = milestone_delay_get_reason_threes(params[:reason_two_id])
      end
      @reason_two_selected = @reason_two_selected.id
    end

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
    error = delay_which_date = delay_days = 0
    old_date_bdd = new_date_bdd = ""
    #old_date_bdd = new_date_bdd = Date.new

    # Check previous and next milestones
    # if (m.project != nil)
    #   sorted_milestones = m.project.sorted_milestones
    #   current_milestone_position = sorted_milestones.index(m)

    #   i = 0
    #   sorted_milestones.each do |m_other|

    #     if (current_milestone_position > i)
         
    #       previous_date = nil
    #       if (m_other.actual_milestone_date != nil)
    #         previous_date = m_other.actual_milestone_date
    #       else
    #         previous_date = m_other.milestone_date
    #       end

    #       if (params[:milestone][:actual_milestone_date] and params[:milestone][:actual_milestone_date].length > 0)
    #         error = 1 if isDateInferior(params[:milestone][:actual_milestone_date], previous_date)
    #       else
    #         error = 1 if isDateInferior(params[:milestone][:milestone_date], previous_date)
    #       end

    #     elsif (current_milestone_position < i)

    #       next_date = nil
    #       if (m_other.actual_milestone_date != nil)
    #         next_date = m_other.actual_milestone_date
    #       else
    #         next_date = m_other.milestone_date
    #       end

    #       if (params[:milestone][:actual_milestone_date] and params[:milestone][:actual_milestone_date].length > 0)
    #         error = 1 if isDateSuperior(params[:milestone][:actual_milestone_date], next_date)
    #       else
    #         error = 1 if isDateSuperior(params[:milestone][:milestone_date], next_date)
    #       end
          
    #     end

    #     i = i + 1
    #   end
    # end


    # Try to update the date, if wrong format = remote
    if params[:milestone][:milestone_date] and params[:milestone][:milestone_date].length > 0
      begin
        date_bdd = Date.parse(params[:milestone][:milestone_date]).strftime("%Y-%m-%d %H:%M:%S")
        if date_bdd
          old_date_bdd = m.milestone_date
          delay_days = old_date_bdd - date_bdd
          new_date_bdd = date_bdd
          m.milestone_date = date_bdd
          delay_which_date = 1
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
          delay_days = old_date_bdd - date_bdd
          new_date_bdd = date_bdd
          m.actual_milestone_date = date_bdd
          delay_which_date = 2
        else
          raise 'Date format error'
        end
      rescue ArgumentError
        error = 2
      end
    else
      m.actual_milestone_date = nil
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

      # Save



      m.save true

      # Redirect
      # if m.done == 1 and old == 0 and m.is_eligible_for_note?
        # redirect_to "/notes/new?project_id=#{m.project_id}&done=1"
      # else
      if delay_which_date > 0
        redirect_to "/milestones/delay?milestone_id=#{m.id}&date_type=#{delay_which_date}&planned_date=#{old_date_bdd}&current_date=#{date_bdd}&delay_days=#{delay_days}"
      else
        redirect_to "/projects/show/#{m.project_id}"
      end
      # end
    else
      # Date error
      redirect_to("/milestones/edit?id=#{params[:id]}&date_error="+error.to_s)
    end
  end

  def delay
    milestone_id = params[:milestone_id]
    milestone = Milestone.find(:first, :conditions=>["id = ?", milestone_id])
    date_type = params[:]
    planned_date = params[:]
    current_date = params[:]
    delay_days = params[:]

    if ((params[:select_reason_one] != "") or (params[:reason_other] != ""))
      milestone_delay = MilestoneDelayRecord.new
      milestone_delay.milestone_id = milestone_id
      milestone_delay.planned_date = old_date_bdd
      milestone_delay.current_date = current_date
      milestone_dealy.delay_days = delay_days
      milestone_dealy.reason_first_id = params[:select_reason_one]
      milestone_dealy.reason_second_id = params[:select_reason_two]
      milestone_dealy.reason_third_id = params[:select_reason_three]
      milestone_dealy.reason_other = params[:reason_other]
      milestone_dealy.updated_by = current_user.id
      milestone_dealy.save
    end

    redirect_to "/projects/show/#{milestone.project_id}"
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
