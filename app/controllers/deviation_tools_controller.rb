class DeviationToolsController < ApplicationController
  layout 'spider'


  # Deliverable 
  def index_deliverable
    @deliverables = DeviationDeliverable.find(:all, :order => "name")
  end

  def detail_deliverable
  	deliverable_id = params[:deliverable_id]
  	if deliverable_id
  		@deliverable = DeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
  	else
		redirect_to :action=>'index_deliverable'
  	end
  end

  def new_deliverable
    @deliverable = DeviationDeliverable.new
  end
  
  def create_deliverable
    deliverable = DeviationDeliverable.new(params[:deliverable])
    deliverable.save
    redirect_to :action=>'detail_deliverable', :deliverable_id=>deliverable.id
  end

  def update_deliverable
    deliverable = DeviationDeliverable.find(params[:deliverable][:id])
    deliverable.update_attributes(params[:deliverable])
    redirect_to :action=>'index_deliverable'
  end

  def delete_deliverable
    deliverable = DeviationDeliverable.find(:first, :conditions=>["id = ?", params[:deliverable_id]])
    if deliverable
      deliverable.destroy
    end
    redirect_to :action=>'index_deliverable'
  end

  # Activity
  def index_activity
    @activities = DeviationActivity.find(:all, :order => "name")
  end

  def detail_activity
    @meta_activities = DeviationMetaActivity.find(:all, :conditions => ["is_active = 1"]).map {|ma| [ma.name, ma.id]}
    @deliverables = DeviationDeliverable.find(:all, :order => "name")

    activity_id = params[:activity_id]
    if activity_id
      @activity = DeviationActivity.find(:first, :conditions => ["id = ?", activity_id])
    else
    redirect_to :action=>'index_activity'
    end
  end

  def new_activity
    @meta_activities = DeviationMetaActivity.find(:all, :conditions => ["is_active = 1"]).map {|ma| [ma.name, ma.id]}
    @deliverables = DeviationDeliverable.find(:all, :order => "name")
    @activity = DeviationActivity.new
  end

  def create_activity
    activity = DeviationActivity.new(params[:activity])
    activity.save

    deliverable_ids = params[:deliverable_ids]
    deliverable_ids.each do |deliverable_id|
      new_activity_deliverable = DeviationActivityDeliverable.new
      new_activity_deliverable.deviation_deliverable_id = deliverable_id
      new_activity_deliverable.deviation_activity_id = activity.id
      new_activity_deliverable.save
    end

    redirect_to :action=>'detail_activity', :activity_id=>activity.id
  end

  def update_activity
    activity = DeviationActivity.find(params[:activity][:id])
    activity.update_attributes(params[:activity])
    
    deliverable_ids = params[:deliverable_ids]
    deliverable_ids.each do |deliverable_id|
      new_activity_deliverable = DeviationActivityDeliverable.new
      new_activity_deliverable.deviation_deliverable_id = deliverable_id
      new_activity_deliverable.deviation_activity_id = activity.id
      new_activity_deliverable.save
    end

    redirect_to :action=>'index_activity'
  end

  def delete_activity
    activity = DeviationActivity.find(:first, :conditions=>["id = ?", params[:activity_id]])
    if activity
      activity.destroy
    end
    redirect_to :action=>'index_activity'
  end

  # Meta Activity
  def index_meta_activity
    @meta_activities = DeviationMetaActivity.find(:all, :order => "name")
  end

  def detail_meta_activity
    meta_activity_id = params[:meta_activity_id]
    if meta_activity_id
      @meta_activity = DeviationMetaActivity.find(:first, :conditions => ["id = ?", meta_activity_id])
    else
    redirect_to :action=>'index_meta_activity'
    end
  end

  def new_meta_activity
    @meta_activity = DeviationMetaActivity.new
  end

  def create_meta_activity
    meta_activity = DeviationMetaActivity.new(params[:meta_activity])
    meta_activity.save
    redirect_to :action=>'detail_meta_activity', :meta_activity_id=>meta_activity.id
  end

  def update_meta_activity
    meta_activity = DeviationMetaActivity.find(params[:meta_activity][:id])
    meat_activity.update_attributes(params[:meta_activity])
    redirect_to :action=>'index_meta_activity'
  end

  def delete_meta_activity
    meta_activity = DeviationMetaActivity.find(:first, :conditions=>["id = ?", params[:meta_activity_id]])
    if meta_activity
      meta_activity.destroy
    end
    redirect_to :action=>'index_meta_activity'
  end

  # Question
  def index_question
    @deliverables = DeviationDeliverable.find(:all, :conditions => ["is_active = 1"]).map {|d| [d.name, d.id]}
    @activities   = DeviationActivity.find(:all, :conditions => ["is_active = 1"]).map {|a| [a.name, a.id]}
    if params[:deliverable_id] != nil
      @deliverable_index_select = params[:deliverable_id]
    else
      @deliverable_index_select = 1
    end
    if params[:activity_id] != nil
      @activity_index_select = params[:activity_id]
    else
      @activity_index_select = 1
    end

    @questions = DeviationQuestion.find(:all, :conditions => ["deviation_deliverable_id = ? and deviation_activity_id = ?", @deliverable_index_select.to_s, @activity_index_select.to_s], :order => "question_text")
  end

 def detail_question
    question_id = params[:question_id]
    if question_id
      @question = DeviationQuestion.find(:first, :conditions => ["id = ?", question_id])
    else
    redirect_to :action=>'index_question'
    end
  end

  def new_question
    #     @lifecycles = Lifecycle.find(:all, :conditions => ["is_active = 1"]).map {|l| [l.name, l.id]}

    activity_id    = params[:activity_id]
    deliverable_id = params[:deliverable_id]
    if activity_id && deliverable_id
      @question = DeviationQuestion.new
      @question.deviation_activity_id = activity_id
      @question.deviation_deliverable_id = deliverable_id
   else
     redirect_to :action=>'index_question'
   end
  end

  def create_question
    question = DeviationQuestion.new(params[:question])
    question.save
    redirect_to :action=>'detail_question', :question_id=>question.id
  end

  def update_question
    question = DeviationQuestion.find(params[:question][:id])
    question.update_attributes(params[:question])
    redirect_to :action=>'index_question', :activity_id=>question.deviation_activity_id, :deliverable_id=>question.deviation_deliverable_id
  end

  def delete_question
    question = DeviationQuestion.find(:first, :conditions=>["id = ?", params[:question_id]])
    if question
      activity_id = question.deviation_activity_id
      deliverable_id = question.deviation_deliverable_id
      question.destroy
      redirect_to :action=>'index_question', :activity_id=>activity_id, :deliverable_id=>deliverable_id
    else
      redirect_to :action=>'index_question'
    end
  end
end
