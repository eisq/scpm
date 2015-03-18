class CreateSvtDeviationSpiderDeliverables < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_spider_deliverables do |t|
      t.integer :deviation_spider_id
      t.integer :deviation_deliverable_id
      t.timestamps
      t.boolean :not_done, :default => false
      t.boolean :is_added_by_hand, :default => false
    end
  end

  def self.down
    drop_table :svt_deviation_spider_deliverables
  end
end