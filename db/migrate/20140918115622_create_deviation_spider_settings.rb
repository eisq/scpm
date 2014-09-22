class CreateDeviationSpiderSettings < ActiveRecord::Migration
  def self.up
    create_table :deviation_spider_settings do |t|
      t.integer :devia_spider_reference_id
      t.integer :deviation_deliverable_id
      t.integer :deviation_activity_id
      t.text :answer_1
      t.text :answer_2
      t.text :answer_3
      t.text    :justification
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_settings
  end
end
