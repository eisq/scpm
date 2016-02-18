class CreateSvfDeviationSpiderSettings < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_spider_settings do |t|
      t.integer :svf_deviation_spider_reference_id
      t.string :deliverable_name
      t.string :activity_name
      t.string :answer_1
      t.string :answer_2
      t.string :answer_3
      t.text    :justification
      t.timestamps
      t.string    :macro_activity_name
    end
  end

  def self.down
    drop_table :svf_deviation_spider_settings
  end
end