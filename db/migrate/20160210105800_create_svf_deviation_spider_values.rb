class CreateSvfDeviationSpiderValues < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_spider_values do |t|
      t.integer :svf_deviation_spider_deliverable_id
      t.integer :svf_deviation_question_id
      t.boolean :answer
      t.boolean :answer_reference
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_spider_values
  end
end