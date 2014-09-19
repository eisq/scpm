class DeviationToolsController < ApplicationController
  layout 'spider'


  # Deliverable 
  def index_deliverable
  	@lifecycles = Lifecycle.find(:all, :conditions => ["is_active = 1"]).map {|l| [l.name, l.id]}
    if params[:lifecycle_id] != nil
      @lifecycle_index_select = params[:lifecycle_id]
    else
      @lifecycle_index_select = 1
    end

    @deliverables = DeviationDeliverable.find(:all, :conditions => ["lifecycle_id = ?", @lifecycle_index_select.to_s], :order => "milestone_name_id, name")
  end

  def detail_deliverable
  	deliverable_id = params[:deliverable_id]
  	if deliverable_id
  		@milestone_names = MilestoneName.find(:all, :conditions => ["is_active = 1"]).map {|m| [m.title, m.id]}
  		@deliverable = DeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
  	else
		redirect_to :action=>'index_deliverable'
  	end
  end

  def new_deliverable
  	lifecycle_id = params[:lifecycle_id]
  	if lifecycle_id
	  	new_deliverable = DeviationDeliverable.new
	  	new_deliverable.lifecycle_id = lifecycle_id
	  	new_deliverable.name = "NEW DELIVERABLE - REPLACE IT"
      new_deliverable.milestone_name = MilestoneName.find(:first)
	  	new_deliverable.save

	  	redirect_to :action=>'index_deliverable', :lifecycle_id=>lifecycle_id
	 else
	   redirect_to :action=>'index_deliverable'
	 end
  end
  
  def update_deliverable
    deliverable = DeviationDeliverable.find(params[:deliverable][:id])
    deliverable.update_attributes(params[:deliverable])
    redirect_to :action=>'index_deliverable', :lifecycle_id=>deliverable.lifecycle_id
  end

  def delete_deliverable
    deliverable = DeviationDeliverable.find(:first, :conditions=>["id = ?", params[:deliverable_id]])
    if deliverable
      lifecycle_id = deliverable.lifecycle_id
      deliverable.destroy
      redirect_to :action=>'index_deliverable', :lifecycle_id=>lifecycle_id
    else
      redirect_to :action=>'index_deliverable'
    end
  end

  # Activity
  def index_activity
    @activities = DeviationActivity.find(:all, :order => "name")
  end

  def detail_activity
    activity_id = params[:activity_id]
    if activity_id
      @activity = DeviationActivity.find(:first, :conditions => ["id = ?", activity_id])
    else
    redirect_to :action=>'index_activity'
    end
  end

  def new_activity
    new_activity = DeviationActivity.new
    new_activity.name = "NEW ACTIVITY - REPLACE IT"
    new_activity.save

    redirect_to :action=>'index_activity'
  end

  def update_activity
    activity = DeviationActivity.find(params[:activity][:id])
    activity.update_attributes(params[:activity])
    redirect_to :action=>'index_activity'
  end

  def delete_activity
    activity = DeviationActivity.find(:first, :conditions=>["id = ?", params[:activity_id]])
    if activity
      activity.destroy
    end
    redirect_to :action=>'index_activity'
  end

end
