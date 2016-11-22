class CreateMdelayReasonOnes < ActiveRecord::Migration
  def self.up
    create_table :mdelay_reason_ones do |t|
      t.string :reason_description
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :mdelay_reason_ones
  end
end