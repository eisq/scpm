class CreateSvtDeviationSpiderActivityValues < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_spider_activity_values do |t|
      t.integer :deviation_spider_id
      t.integer :deviation_activity_id
      t.integer :yes_counter
      t.integer :no_counter
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_spider_activity_values
  end
end