class SvfDeviationToolsController < ApplicationController
  layout 'tools'


  # Deliverable 
  def index_deliverable
    @deliverables = SvfDeviationDeliverable.find(:all, :order => "name")
  end

  def detail_deliverable
  	deliverable_id = params[:deliverable_id]
  	if deliverable_id
  		@deliverable = SvfDeviationDeliverable.find(:first, :conditions => ["id = ?", deliverable_id])
  	else
		redirect_to :action=>'index_deliverable'
  	end
  end

  def new_deliverable
    @deliverable = SvfDeviationDeliverable.new
  end
  
  def create_deliverable
    deliverable = SvfDeviationDeliverable.new(params[:deliverable])
    deliverable.save
    redirect_to :action=>'detail_deliverable', :deliverable_id=>deliverable.id
  end

  def update_deliverable
    deliverable = SvfDeviationDeliverable.find(params[:deliverable][:id])
    deliverable.update_attributes(params[:deliverable])
    redirect_to :action=>'index_deliverable'
  end

  def delete_deliverable
    deliverable = SvfDeviationDeliverable.find(:first, :conditions=>["id = ?", params[:deliverable_id]])
    if deliverable
      deliverable.destroy
    end
    redirect_to :action=>'index_deliverable'
  end

  # Activity
  def index_activity
    @activities = SvfDeviationActivity.find(:all, :order => "name")
  end  

  def detail_activity
    @meta_activities = SvfDeviationMetaActivity.find(:all, :conditions => ["is_active = 1"], :order => "meta_index").map {|ma| [ma.name, ma.id]}
    @deliverables = SvfDeviationDeliverable.find(:all, :conditions => ["is_active = 1"], :order => "name")

    activity_id = params[:activity_id]
    if activity_id
      @activity = SvfDeviationActivity.find(:first, :conditions => ["id = ?", activity_id])
    else
    redirect_to :action=>'index_activity'
    end
  end

  def new_activity
    @meta_activities = SvfDeviationMetaActivity.find(:all, :conditions => ["is_active = 1"], :order => "meta_index").map {|ma| [ma.name, ma.id]}
    @deliverables = SvfDeviationDeliverable.find(:all, :conditions => ["is_active = 1"], :order => "name")
    @activity = SvfDeviationActivity.new
  end

  def create_activity
    activity = SvfDeviationActivity.new(params[:activity])
    activity.save

    deliverable_ids = params[:deliverable_ids]
    if deliverable_ids
      deliverable_ids.each do |deliverable_id|
        new_activity_deliverable = SvfDeviationActivityDeliverable.new
        new_activity_deliverable.svf_deviation_deliverable_id = deliverable_id
        new_activity_deliverable.svf_deviation_activity_id = activity.id
        new_activity_deliverable.save
      end
    end
    redirect_to :action=>'detail_activity', :activity_id=>activity.id
  end

  def update_activity
    activity = SvfDeviationActivity.find(params[:activity][:id])
    activity.update_attributes(params[:activity])
    
    deliverable_ids = params[:deliverable_ids]
    if deliverable_ids
      deliverable_ids.each do |deliverable_id|
        new_activity_deliverable = SvfDeviationActivityDeliverable.new
        new_activity_deliverable.svf_deviation_deliverable_id = deliverable_id
        new_activity_deliverable.svf_deviation_activity_id = activity.id
        new_activity_deliverable.save
      end
    end
    redirect_to :action=>'index_activity'
  end

  def delete_activity
    activity = SvfDeviationActivity.find(:first, :conditions=>["id = ?", params[:activity_id]])
    if activity
      activity.destroy
    end
    redirect_to :action=>'index_activity'
  end

  # Macro Activity
  def index_macro_activity
    @macro_activities = SvfDeviationMacroActivity.find(:all, :order => "name")
  end

  def detail_macro_activity
    @activities = SvfDeviationActivity.find(:all, :conditions => ["is_active = 1"], :order => "name").map {|a| [a.name, a.id]}
    @deliverables = SvfDeviationDeliverable.find(:all, :conditions => ["is_active = 1"], :order => "name")

    macro_activity_id = params[:macro_activity_id]
    if macro_activity_id
      @macro_activity = SvfDeviationMacroActivity.find(:first, :conditions => ["id = ?", macro_activity_id])
    else
    redirect_to :action=>'index_macro_activity'
    end
  end

  def new_macro_activity
    @activities = SvfDeviationActivity.find(:all, :conditions => ["is_active = 1"], :order => "name").map {|a| [a.name, a.id]}
    @deliverables = SvfDeviationDeliverable.find(:all, :conditions => ["is_active = 1"], :order => "name")
    @macro_activity = SvfDeviationMacroActivity.new
  end

  def create_macro_activity
    macro_activity = SvfDeviationMacroActivity.new(params[:macro_activity])
    macro_activity.save

    deliverable_ids = params[:deliverable_ids]
    if deliverable_ids
      deliverable_ids.each do |deliverable_id|
        new_macro_activity_deliverable = SvfDeviationMacroActivityDeliverable.new
        new_macro_activity_deliverable.svf_deviation_deliverable_id = deliverable_id
        new_macro_activity_deliverable.svf_deviation_macro_activity_id = macro_activity.id
        new_macro_activity_deliverable.save
      end
    end
    redirect_to :action=>'detail_macro_activity', :macro_activity_id=>macro_activity.id
  end

  def update_macro_activity
    macro_activity = SvfDeviationMacroActivity.find(params[:macro_activity][:id])
    macro_activity.update_attributes(params[:macro_activity])
    
    deliverable_ids = params[:deliverable_ids]
    if deliverable_ids
      deliverable_ids.each do |deliverable_id|
        new_macro_activity_deliverable = SvfDeviationMacroActivityDeliverable.new
        new_macro_activity_deliverable.svf_deviation_deliverable_id = deliverable_id
        new_macro_activity_deliverable.svf_deviation_macro_activity_id = macro_activity.id
        new_macro_activity_deliverable.save
      end
    end
    redirect_to :action=>'index_macro_activity'
  end

  def delete_macro_activity
    macro_activity = SvfDeviationMacroActivity.find(:first, :conditions=>["id = ?", params[:macro_activity_id]])
    if macro_activity
      macro_activity.destroy
    end
    redirect_to :action=>'index_macro_activity'
  end

  # Meta Activity
  def index_meta_activity
    @meta_activities = SvfDeviationMetaActivity.find(:all, :order=>"meta_index")
  end

  def detail_meta_activity
    meta_activity_id = params[:meta_activity_id]
    if meta_activity_id
      @meta_activity = SvfDeviationMetaActivity.find(:first, :conditions => ["id = ?", meta_activity_id], :order=>"meta_index")
    else
    redirect_to :action=>'index_meta_activity'
    end
  end

  def new_meta_activity
    @meta_activity = SvfDeviationMetaActivity.new
  end

  def create_meta_activity
    meta_activity = SvfDeviationMetaActivity.new(params[:meta_activity])
    meta_activity.save
    redirect_to :action=>'detail_meta_activity', :meta_activity_id=>meta_activity.id
  end

  def update_meta_activity
    meta_activity = SvfDeviationMetaActivity.find(params[:meta_activity][:id])
    meta_activity.update_attributes(params[:meta_activity])
    redirect_to :action=>'index_meta_activity'
  end

  def delete_meta_activity
    meta_activity = SvfDeviationMetaActivity.find(:first, :conditions=>["id = ?", params[:meta_activity_id]])
    if meta_activity
      meta_activity.destroy
    end
    redirect_to :action=>'index_meta_activity'
  end

  # Question
  def index_question
    @activities   = SvfDeviationActivity.find(:all, :conditions => ["is_active = 1"]).map {|a| [a.name, a.id]}
    if params[:activity_id] != nil
      @activity_index_select = params[:activity_id]
    else
      if @activities.count > 0
        @activity_index_select = @activities[0][1]
      else
        @activity_index_select = 1
      end
    end

    deliverables = SvfDeviationDeliverable.find(:all, :joins => ["JOIN svf_deviation_activity_deliverables ON svf_deviation_activity_deliverables.svf_deviation_deliverable_id = svf_deviation_deliverables.id"], :conditions => ["is_active = 1 and svf_deviation_activity_deliverables.svf_deviation_activity_id = ?", @activity_index_select]).map {|d| [d.name, d.id]}
    @deliverables = deliverables & deliverables
    if params[:deliverable_id] != nil
      @deliverable_index_select = params[:deliverable_id]
    else
      if @deliverables.count > 0
        @deliverable_index_select = @deliverables[0][1]
      else
        @deliverable_index_select = 1
      end
    end
    @questions = SvfDeviationQuestion.find(:all, :conditions => ["svf_deviation_deliverable_id = ? and svf_deviation_activity_id = ?", @deliverable_index_select.to_s, @activity_index_select.to_s], :order => "question_text")
  end

 def detail_question
    @lifecycles      = Lifecycle.find(:all, :conditions => ["is_active = 1"])
    @milestone_names = MilestoneName.find(:all, :conditions => ["is_active = 1"])

    question_id = params[:question_id]
    if question_id
      @question = SvfDeviationQuestion.find(:first, :conditions => ["id = ?", question_id])
    else
    redirect_to :action=>'index_question'
    end
  end

  def new_question
    @lifecycles      = Lifecycle.find(:all, :conditions => ["is_active = 1"])
    @milestone_names = MilestoneName.find(:all, :conditions => ["is_active = 1"]).sort_by {|m| [ m.title ] }

    activity_id    = params[:activity_id]
    deliverable_id = params[:deliverable_id]
    if activity_id && deliverable_id
      @question = SvfDeviationQuestion.new
      @question.svf_deviation_activity_id = activity_id
      @question.svf_deviation_deliverable_id = deliverable_id
   else
     redirect_to :action=>'index_question'
   end
  end

  def create_question
    question = SvfDeviationQuestion.new(params[:question])
    question.answer_reference = true
    question.save

    lifecycle_ids = params[:lifecycle_ids]
    if lifecycle_ids
      lifecycle_ids.each do |lifecycle_id|
        new_deviation_question_lifecycle = SvfDeviationQuestionLifecycle.new
        new_deviation_question_lifecycle.svf_deviation_question_id = question.id
        new_deviation_question_lifecycle.lifecycle_id = lifecycle_id
        new_deviation_question_lifecycle.save
      end
    end

    milestone_name_ids = params[:milestone_name_ids]
    if milestone_name_ids
      milestone_name_ids.each do |milestone_name_id|
        new_deviation_question_milestone_name = SvfDeviationQuestionMilestoneName.new
        new_deviation_question_milestone_name.svf_deviation_question_id = question.id
        new_deviation_question_milestone_name.milestone_name_id = milestone_name_id
        new_deviation_question_milestone_name.save
      end
    end

    redirect_to :action=>'detail_question', :question_id=>question.id
  end

  def update_question
    question = SvfDeviationQuestion.find(params[:question][:id])
    question.update_attributes(params[:question])

    lifecycle_ids = params[:lifecycle_ids]
    if lifecycle_ids
      lifecycle_ids.each do |lifecycle_id|
        questionlifecycle = SvfDeviationQuestionLifecycle.find(:first, :conditions=>["svf_deviation_question_id = ? and lifecycle_id = ?", question.id, lifecycle_id])
        if !questionlifecycle
          new_deviation_question_lifecycle = SvfDeviationQuestionLifecycle.new
          new_deviation_question_lifecycle.svf_deviation_question_id = question.id
          new_deviation_question_lifecycle.lifecycle_id = lifecycle_id
          new_deviation_question_lifecycle.save
        end
      end

      #Delete non-checked lifecycles
      to_remove = 1
      SvfDeviationQuestionLifecycle.find(:all, :conditions=>["svf_deviation_question_id = ?", question.id]).each do |q|
        lifecycle_ids.each do |lifecycle_id_to_remove|
          if lifecycle_id_to_remove.to_s == q.lifecycle_id.to_s
            to_remove = 0
          end
        end

        if to_remove == 1
          q.delete
        else
          to_remove = 1
        end
      end
    end    

    milestone_name_ids = params[:milestone_name_ids]
    if milestone_name_ids
      milestone_name_ids.each do |milestone_name_id|
        questionmilestone = SvfDeviationQuestionMilestoneName.find(:first, :conditions=>["svf_deviation_question_id = ? and milestone_name_id = ?", question.id, milestone_name_id])
        if !questionmilestone
          new_deviation_question_milestone_name = SvfDeviationQuestionMilestoneName.new
          new_deviation_question_milestone_name.svf_deviation_question_id = question.id
          new_deviation_question_milestone_name.milestone_name_id = milestone_name_id
          new_deviation_question_milestone_name.save
        end
      end

      #Delete non-checked milestones
      to_remove = 1
      SvfDeviationQuestionMilestoneName.find(:all, :conditions=>["svf_deviation_question_id = ?", question.id]).each do |q|
        milestone_name_ids.each do |milestone_id_to_remove|
          if milestone_id_to_remove.to_s == q.milestone_name_id.to_s
            to_remove = 0
          end
        end

        if to_remove == 1
          q.delete
        else
          to_remove = 1
        end
      end
    end

    redirect_to :action=>'index_question', :activity_id=>question.svf_deviation_activity_id, :deliverable_id=>question.svf_deviation_deliverable_id
  end

  def delete_question
    question = SvfDeviationQuestion.find(:first, :conditions=>["id = ?", params[:question_id]])
    if question
      activity_id = question.svf_deviation_activity_id
      deliverable_id = question.svf_deviation_deliverable_id
      question.destroy
      redirect_to :action=>'index_question', :activity_id=>activity_id, :deliverable_id=>deliverable_id
    else
      redirect_to :action=>'index_question'
    end
  end
end
