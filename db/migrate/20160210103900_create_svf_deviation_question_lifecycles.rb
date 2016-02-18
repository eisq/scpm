class CreateSvfDeviationQuestionLifecycles < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_question_lifecycles do |t|
      t.integer  :svf_deviation_question_id
      t.integer  :lifecycle_id
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_question_lifecycles
  end
end