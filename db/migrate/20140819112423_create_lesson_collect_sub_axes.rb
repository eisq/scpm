class CreateLessonCollectSubAxes < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_sub_axes do |t|
    	t.string 	:name
    	t.integer	:lesson_collect_axe_id
    end
  end

  def self.down
    drop_table :lesson_collect_sub_axes
  end
end
