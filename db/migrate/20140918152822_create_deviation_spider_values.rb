class CreateDeviationSpiderValues < ActiveRecord::Migration
  def self.up
    create_table :deviation_spider_values do |t|
      t.integer :deviation_spider_deliverable_id
      t.integer :deviation_question_id
      t.boolean :answer
      t.bollean :answer_reference
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_values
  end
end
