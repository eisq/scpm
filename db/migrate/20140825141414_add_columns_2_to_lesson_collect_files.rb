class AddColumns2ToLessonCollectFiles < ActiveRecord::Migration
  def self.up
  	add_column :lesson_collect_files, :comment, :text
  	add_column :lesson_collect_files, :is_archived, :boolean, :default => false
  end

  def self.down
  	remove_column :lesson_collect_files, :comment
  	remove_column :lesson_collect_files, :is_archived
  end
end