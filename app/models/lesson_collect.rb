class LessonCollect < ActiveRecord::Base
  belongs_to  	:lesson_collect_file
  belongs_to	:lesson_collect_axe
  belongs_to	:lesson_collect_sub_axe
end
