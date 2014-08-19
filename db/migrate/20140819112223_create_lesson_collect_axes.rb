class CreateLessonCollectAxes < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_axes do |t|
    	t.string 	:name
    end
  end

  def self.down
    drop_table :lesson_collect_axes
  end
end
