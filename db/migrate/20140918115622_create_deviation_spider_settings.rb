class CreateDeviationSpiderSettings < ActiveRecord::Migration
  def self.up
    create_table :deviation_spider_settings do |t|
      t.integer :devia_spider_reference_id
      t.integer :deviation_deliverable_id
      t.integer :deviation_activity_id
      t.boolean :answer_1, :default => false
      t.boolean :answer_2, :default => false
      t.boolean :answer_3, :default => false
      t.text    :justification
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_settings
  end
end
