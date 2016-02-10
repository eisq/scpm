class CreateSvfDeviationSpiderDeliverables < ActiveRecord::Migration
  def self.up
    create_table :svf_deviation_spider_deliverables do |t|
      t.integer :svf_deviation_spider_id
      t.integer :svf_deviation_deliverable_id
      t.timestamps
      t.boolean :not_done, :default => false
      t.boolean :is_added_by_hand, :default => false
    end
  end

  def self.down
    drop_table :svf_deviation_spider_deliverables
  end
end