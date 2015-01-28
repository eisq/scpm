class CreateDeviationQuestionLifecycles < ActiveRecord::Migration
  def self.up
    create_table :deviation_question_lifecycles do |t|
      t.integer  :deviation_question_id
      t.integer  :lifecycle_id
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_question_lifecycles
  end
end
