class DeviationToolsController < ApplicationController
  layout 'tools'


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
    @deliverables = DeviationDeliverable.find(:all, :conditions => ["is_active = 1"], :order => "name")

    activity_id = params[:activity_id]
    if activity_id
      @activity = DeviationActivity.find(:first, :conditions => ["id = ?", activity_id])
    else
    redirect_to :action=>'index_activity'
    end
  end

  def new_activity
    @meta_activities = DeviationMetaActivity.find(:all, :conditions => ["is_active = 1"]).map {|ma| [ma.name, ma.id]}
    @deliverables = DeviationDeliverable.find(:all, :conditions => ["is_active = 1"], :order => "name")
    @activity = DeviationActivity.new
  end

  def create_activity
    activity = DeviationActivity.new(params[:activity])
    activity.save

    deliverable_ids = params[:deliverable_ids]
    if deliverable_ids
      deliverable_ids.each do |deliverable_id|
        new_activity_deliverable = DeviationActivityDeliverable.new
        new_activity_deliverable.deviation_deliverable_id = deliverable_id
        new_activity_deliverable.deviation_activity_id = activity.id
        new_activity_deliverable.save
      end
    end
    redirect_to :action=>'detail_activity', :activity_id=>activity.id
  end

  def update_activity
    activity = DeviationActivity.find(params[:activity][:id])
    activity.update_attributes(params[:activity])
    
    deliverable_ids = params[:deliverable_ids]
    if deliverable_ids
      deliverable_ids.each do |deliverable_id|
        new_activity_deliverable = DeviationActivityDeliverable.new
        new_activity_deliverable.deviation_deliverable_id = deliverable_id
        new_activity_deliverable.deviation_activity_id = activity.id
        new_activity_deliverable.save
      end
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
    meta_activity.update_attributes(params[:meta_activity])
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
    @activities   = DeviationActivity.find(:all, :conditions => ["is_active = 1"]).map {|a| [a.name, a.id]}
    if params[:activity_id] != nil
      @activity_index_select = params[:activity_id]
    else
      if @activities.count > 0
        @activity_index_select = @activities[0][1]
      else
        @activity_index_select = 1
      end
    end

    @deliverables = DeviationDeliverable.find(:all, :joins => ["JOIN deviation_activity_deliverables ON deviation_activity_deliverables.deviation_deliverable_id = deviation_deliverables.id"], :conditions => ["is_active = 1 and deviation_activity_deliverables.deviation_activity_id = ?", @activity_index_select]).map {|d| [d.name, d.id]}
    if params[:deliverable_id] != nil
      @deliverable_index_select = params[:deliverable_id]
    else
      if @deliverables.count > 0
        @deliverable_index_select = @deliverables[0][1]
      else
        @deliverable_index_select = 1
      end
    end
    @questions = DeviationQuestion.find(:all, :conditions => ["deviation_deliverable_id = ? and deviation_activity_id = ?", @deliverable_index_select.to_s, @activity_index_select.to_s], :order => "question_text")
  end

 def detail_question
    @lifecycles      = Lifecycle.find(:all, :conditions => ["is_active = 1"])
    @milestone_names = MilestoneName.find(:all, :conditions => ["is_active = 1"])

    question_id = params[:question_id]
    if question_id
      @question = DeviationQuestion.find(:first, :conditions => ["id = ?", question_id])
    else
    redirect_to :action=>'index_question'
    end
  end

  def new_question
    @lifecycles      = Lifecycle.find(:all, :conditions => ["is_active = 1"])
    @milestone_names = MilestoneName.find(:all, :conditions => ["is_active = 1"])

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
    question.answer_reference = true
    question.save

    lifecycle_ids = params[:lifecycle_ids]
    if lifecycle_ids
      lifecycle_ids.each do |lifecycle_id|
        new_deviation_question_lifecycle = DeviationQuestionLifecycle.new
        new_deviation_question_lifecycle.deviation_question_id = question.id
        new_deviation_question_lifecycle.lifecycle_id = lifecycle_id
        new_deviation_question_lifecycle.save
      end
    end

    milestone_name_ids = params[:milestone_name_ids]
    if milestone_name_ids
      milestone_name_ids.each do |milestone_name_id|
        new_deviation_question_milestone_name = DeviationQuestionMilestoneName.new
        new_deviation_question_milestone_name.deviation_question_id = question.id
        new_deviation_question_milestone_name.milestone_name_id = milestone_name_id
        new_deviation_question_milestone_name.save
      end
    end

    redirect_to :action=>'detail_question', :question_id=>question.id
  end

  def update_question
    question = DeviationQuestion.find(params[:question][:id])
    question.update_attributes(params[:question])

    lifecycle_ids = params[:lifecycle_ids]
    if lifecycle_ids
      lifecycle_ids.each do |lifecycle_id|
        new_deviation_question_lifecycle = DeviationQuestionLifecycle.new
        new_deviation_question_lifecycle.deviation_question_id = question.id
        new_deviation_question_lifecycle.lifecycle_id = lifecycle_id
        new_deviation_question_lifecycle.save
      end
    end

    milestone_name_ids = params[:milestone_name_ids]
    if milestone_name_ids
      milestone_name_ids.each do |milestone_name_id|
        new_deviation_question_milestone_name = DeviationQuestionMilestoneName.new
        new_deviation_question_milestone_name.deviation_question_id = question.id
        new_deviation_question_milestone_name.milestone_name_id = milestone_name_id
        new_deviation_question_milestone_name.save
      end
    end

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
