class CreateDeviationDeliverables < ActiveRecord::Migration
  def self.up
    create_table :deviation_deliverables do |t|
      t.integer :lifecycle_id
      t.integer :milestone_name_id
      t.string  :name
      t.boolean :is_active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :deviation_deliverables
  end
end
