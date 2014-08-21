class LessonCollectSubAxe < ActiveRecord::Base
 belongs_to :lesson_collect_axe
 has_many	:lesson_collects
end
