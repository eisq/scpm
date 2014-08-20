class AddMtQrToLessonCollectFiles < ActiveRecord::Migration
  def self.up
  	add_column :lesson_collect_files, :mt_qr, :string
  end

  def self.down
  	remove_column :lesson_collect_files, :mt_qr
  end
end