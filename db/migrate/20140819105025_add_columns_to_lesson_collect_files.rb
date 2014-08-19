class AddColumnsToLessonCollectFiles < ActiveRecord::Migration
  def self.up
  	add_column :lesson_collect_files, :lesson_collect_template_type_id, :integer
    add_column :lesson_collect_files, :request_id, :integer
  end

  def self.down
  	remove_column :lesson_collect_files, :lesson_collect_template_type_id
    remove_column :lesson_collect_files, :request_id
  end
end