class CreateDeviationQuestionMilestoneNames < ActiveRecord::Migration
  def self.up
    create_table :deviation_question_milestone_names do |t|
      t.integer  :deviation_question_id
      t.integer  :milestone_name_id
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_question_milestone_names
  end
end
