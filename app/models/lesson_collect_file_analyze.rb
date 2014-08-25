class LessonCollectFileAnalyze < ActiveRecord::Base
	belongs_to :person
	belongs_to :lesson_collect_file
end
