class CreateSvfDeviationQuestionMilestoneNames < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_question_milestone_names do |t|
      t.integer  :svf_deviation_question_id
      t.integer  :milestone_name_id
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_question_milestone_names
  end
end