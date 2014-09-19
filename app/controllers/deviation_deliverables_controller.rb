class DeviationDeliverablesController < ApplicationController
  layout 'spider'


  def index
  	@lifecycles = Lifecycle.find(:all, :conditions => ["is_active = 1"]).map {|l| [l.name, l.id]}
    if params[:lifecycle_id] != nil
      @lifecycle_index_select = params[:lifecycle_id]
    else
      @lifecycle_index_select = 1
    end

    @deliverables = DeviationDeliverable.find(:all, :conditions => ["lifecycle_id = ?", @lifecycle_index_select.to_s])
  end

  def detail
  	deliverable_id = params[:deliverable_id]
  	if deliverable_id
  		@milestone_names = MilestoneName.find(:all, :conditions => ["is_active = 1"]).map {|m| [m.title, m.id]}
  		@deliverable = DeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
  	else
		redirect_to :action=>'index'
  	end
  end

  def new_deliverable
  	lifecycle_id = params[:lifecycle_id]
  	if lifecycle_id
	  	new_deliverable = DeviationDeliverable.new
	  	new_deliverable.lifecycle_id = lifecycle_id
	  	new_deliverable.name = "NEW DELIVERABLE - REPLACE IT"
	  	new_deliverable.save

	  	redirect_to :action=>'index', :lifecycle_id=>lifecycle_id
	 else
	   redirect_to :action=>'index'
	 end
  end
  
  def update_deliverable
    deliverable = DeviationDeliverable.find(params[:deliverable][:id])
    deliverable.update_attributes(params[:deliverable])
    redirect_to :action=>'index', :lifecycle_id=>deliverable.lifecycle_id
  end

  def delete_deliverable
    deliverable = DeviationDeliverable.find(:first, :conditions=>["id = ?", params[:deliverable_id]])
    if deliverable
      lifecycle_id = deliverable.lifecycle_id
      deliverable.destroy
      redirect_to :action=>'index', :lifecycle_id=>lifecycle_id
    else
      redirect_to :action=>'index'
    end
  end
end
