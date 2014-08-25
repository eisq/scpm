class CreateLessonCollectFileAnalyzes < ActiveRecord::Migration
  def self.up
    create_table :lesson_collect_file_analyzes do |t|
    	t.integer	:person_id
      t.integer :lesson_collect_file_id
    	t.string 	:comment
    	t.timestamps
    end
  end

  def self.down
    drop_table :lesson_collect_file_analyzes
  end
end
