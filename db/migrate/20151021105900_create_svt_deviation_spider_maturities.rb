class CreateSvtDeviationSpiderMaturities < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_spider_maturities do |t|
      t.integer :svt_deviation_spider_id
      t.integer :svt_deviation_deliverable_id
      t.string :planned
      t.string :achieved
      t.string :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_spider_maturities
  end
end