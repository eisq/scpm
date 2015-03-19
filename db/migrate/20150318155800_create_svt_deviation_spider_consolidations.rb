class CreateSvtDeviationSpiderConsolidations < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_spider_consolidations do |t|
      t.integer :svt_deviation_spider_id
      t.integer :svt_deviation_deliverable_id
      t.integer :svt_deviation_activity_id
      t.integer :score
      t.text :justification
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_spider_consolidations
  end
end