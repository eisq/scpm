class ContextChooserController < ApplicationController

  layout 'login'

  #def background
  #  render(:text=>"/images/bg/01.jpg")
  #end

  def index
    now = DateTime.now
  	@actions      = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress')", current_user.id], :order=>"due_date")
  	@action_48hr  = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress') and updated_at >= ?", current_user.id, now - 48.hours], :order=>"due_date")
  	@actions_old = Action.find(:all, :conditions=>["person_id=? and progress in('open','in_progress') and updated_at < ?", current_user.id, now - 48.hours], :order=>"due_date")
  end


end

