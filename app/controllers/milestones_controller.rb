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

    @first_reasons = MilestoneDelayReasonOne.find(:all, :conditions=>["is_active = ?", true])
    @second_reasons = MilestoneDelayReasonTwo.find(:all, :conditions=>["is_active = ?", true])
    @third_reasons = MilestoneDelayReasonThird.find(:all, :conditions=>["is_active = ?", true])

    get_infos
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
          old_date_bdd = m.milestone_date
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

    if delay_which_date > 0
      if (params[:delay][:first_id] and params[:delay][:first_id].length > 0) or (params[:delay][:other] and params[:delay][:other].length > 0)
        milestone_delay = MilestoneDelayRecord.new
        milestone_delay.milestone_id = m.id
        milestone_delay.planned_date = old_date_bdd
        milestone_delay.current_date = new_date_bdd
        milestone_dealy.delay_days = delay_days
        milestone_dealy.reason_first_id = params[:delay][:first_id]
        milestone_dealy.reason_second_id = params[:delay][:second_id]
        milestone_dealy.reason_third_id = params[:delay][:third_id]
        milestone_dealy.reason_other = params[:delay][:other]
        milestone_dealy.updated_by = current_user.id
      else
        error = 3
      end
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
        redirect_to "/projects/show/#{m.project_id}"
      # end
    else
      # Date error
      redirect_to("/milestones/edit?id=#{params[:id]}&date_error="+error.to_s)
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
