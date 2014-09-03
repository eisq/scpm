class LessonCollectAxe < ActiveRecord::Base
 has_many   :lesson_collect_sub_axes, :class_name=>"LessonCollectSubAxe", :dependent=>:destroy
 has_many	:lesson_collects
end
