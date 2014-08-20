class AddFilenameToLessonCollectFiles < ActiveRecord::Migration
  def self.up
  	add_column :lesson_collect_files, :filename, :string
  end

  def self.down
  	remove_column :lesson_collect_files, :filename
  end
end