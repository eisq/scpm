class CreateDeviationQuestions < ActiveRecord::Migration
  def self.up
    create_table :deviation_questions do |t|
      t.integer :deviation_deliverable_id
      t.integer :deviation_activity_id
      t.integer :milestone_id
      t.text    :question_text
      t.boolean :is_active, :default => true
      t.boolean :answer_reference, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_questions
  end
end
