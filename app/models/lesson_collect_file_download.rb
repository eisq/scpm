class LessonCollectFileDownload < ActiveRecord::Base
	belongs_to :person, :class_name=>"Person", :foreign_key=>"user_id"
	belongs_to :lesson_collect_file
end
