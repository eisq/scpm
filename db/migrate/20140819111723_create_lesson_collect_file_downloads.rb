class CreateLessonCollectFileDownloads < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_file_downloads do |t|
    	t.integer 	:user_id
    	t.integer 	:lesson_collect_file_id
    	t.datetime 	:download_date
    end
  end

  def self.down
    drop_table :lesson_collect_file_downloads
  end
end
