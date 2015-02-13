class CreateCiProjectDelays < ActiveRecord::Migration
  def self.up
    create_table :ci_project_delays do |t|
      t.integer  :id
      t.integer  :ci_project_id
      t.string  :title
      t.string  :justification
      t.timestamps
    end
  end

  def self.down
    drop_table :ci_project_delays
  end
end
