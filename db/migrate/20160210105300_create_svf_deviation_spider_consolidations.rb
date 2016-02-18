class CreateSvfDeviationSpiderConsolidations < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_spider_consolidations do |t|
      t.integer :svf_deviation_spider_id
      t.integer :svf_deviation_deliverable_id
      t.integer :svf_deviation_activity_id
      t.integer :score
      t.text :justification
      t.timestamps
    end
  end

  def self.down
    drop_table :svf_deviation_spider_consolidations
  end
end