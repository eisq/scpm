class CreateOnHoldProjects < ActiveRecord::Migration
  def self.up
    create_table :on_hold_projects do |t|
      t.integer :project_id
      t.boolean :on_hold
      t.integer :total, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :on_hold_projects
  end
end