class AddColumnsToLessonCollects < ActiveRecord::Migration
  def self.up
  	add_column :lesson_collects, :lesson_collect_axe_id, :integer
  	add_column :lesson_collects, :lesson_collect_sub_axe_id, :string
  	add_column :lesson_collects, :escalate_next_level, :string
  	add_column :lesson_collects, :project_name, :string
  	add_column :lesson_collects, :action_plan, :boolean
  	add_column :lesson_collects, :already_exist, :boolean
  	add_column :lesson_collects, :redundancy, :string
  	add_column :lesson_collects, :selected, :boolean
  	add_column :lesson_collects, :status, :string
  	add_column :lesson_collects, :raised_in_dws_plm, :string
  end

  def self.down
  	remove_column :lesson_collects, :lesson_collect_axe_id
  	remove_column :lesson_collects, :lesson_collect_sub_axe_id
  	remove_column :lesson_collects, :escalate_next_level
  	remove_column :lesson_collects, :project_name
  	remove_column :lesson_collects, :action_plan
  	remove_column :lesson_collects, :already_exist
  	remove_column :lesson_collects, :redundancy
  	remove_column :lesson_collects, :selected
  	remove_column :lesson_collects, :status
  	remove_column :lesson_collects, :raised_in_dws_plm
  end
end