class CreateSvtDeviationDeliverables < ActiveRecord::Migration
  def self.up
    create_table :svt_deviation_deliverables do |t|
      t.string  :name
      t.boolean :is_active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :svt_deviation_deliverables
  end
end