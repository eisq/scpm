class CreateSvfDeviationQuestions < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_questions do |t|
      t.integer :svf_deviation_deliverable_id
      t.integer :svf_deviation_activity_id
      t.text    :question_text
      t.boolean :is_active, :default => true
      t.boolean :answer_reference, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_questions
  end
end