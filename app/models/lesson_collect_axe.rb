class LessonCollectAxe < ActiveRecord::Base
 has_many    :lesson_collect_sub_axes, :dependent=>:destroy
end
