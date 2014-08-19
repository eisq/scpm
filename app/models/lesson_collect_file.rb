class LessonCollectFile < ActiveRecord::Base
 has_many    :lesson_collects, 					:dependent=>:destroy
 has_many    :lesson_collect_actions,   		:dependent=>:destroy
 has_many    :lesson_collect_assessments,   	:dependent=>:destroy
 has_many    :lesson_collect_file_downloads,   	:dependent=>:destroy
 belongs_to	 :lesson_collect_template_type
 belongs_to	 :request
end
