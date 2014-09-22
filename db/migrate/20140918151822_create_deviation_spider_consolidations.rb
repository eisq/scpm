class CreateDeviationSpiderConsolidations < ActiveRecord::Migration
  def self.up
    create_table :deviation_spider_consolidations do |t|
      t.integer :deviation_spider_id
      t.integer :deviation_deliverable_id
      t.integer :deviation_activity_id
      t.integer :score
      t.text :justification
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_spider_consolidations
  end
end
