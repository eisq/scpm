class CreateLessonCollectTemplateTypes < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_template_types do |t|
    	t.string :name
    end
  end

  def self.down
    drop_table :lesson_collect_template_types
  end
end
