class LessonCollectFileDownload < ActiveRecord::Base
	belongs_to :user
	belongs_to :lesson_collect_file
end
