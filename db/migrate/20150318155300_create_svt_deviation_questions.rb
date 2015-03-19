class CreateSvtDeviationQuestions < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_questions do |t|
      t.integer :svt_deviation_deliverable_id
      t.integer :svt_deviation_activity_id
      t.text    :question_text
      t.boolean :is_active, :default => true
      t.boolean :answer_reference, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_questions
  end
end