class LessonCollectFile < ActiveRecord::Base
 has_many    :lesson_collects, 					:dependent=>:destroy
 has_many    :lesson_collect_actions,   		:dependent=>:destroy
 has_many    :lesson_collect_assessments,   	:dependent=>:destroy
 has_many    :lesson_collect_file_downloads,   	:dependent=>:destroy
 belongs_to	 :lesson_collect_template_type
 has_many 	 :lesson_collect_file_analyzes
 belongs_to	 :request



 def get_axes
 	result = Array.new
 	self.lesson_collects.each do |l|
 		if l.lesson_collect_axe and !result.include? l.lesson_collect_axe.name
 			result << l.lesson_collect_axe.name
 		end
 	end
 	return result
 end

 def get_sub_axes
 	result = Array.new
 	self.lesson_collects.each do |l|
 		if l.lesson_collect_sub_axe and !result.include? l.lesson_collect_sub_axe.name
 			result << l.lesson_collect_sub_axe.name
 		end
 	end
 	return result
 end

 def get_milestones
 	result = Array.new
 	self.lesson_collects.each do |l|
 		if l.milestone and !result.include? l.milestone
 			result << l.milestone
 		end
 	end
 	return result
 end

 def get_rise
 	result = Array.new
 	self.lesson_collects.each do |l|
 		if l.status and l.status == "Published"
 			result << l
 		end
 	end
 	return result
 end



end
