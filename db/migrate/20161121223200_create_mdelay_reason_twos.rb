class CreateMdelayReasonTwos < ActiveRecord::Migration
  def self.up
    create_table :mdelay_reason_twos do |t|
      t.string :reason_description
      t.integer :mdelay_reason_one_id
      t.boolean :is_active
      t.timestamps
    end
  end

  def self.down
    drop_table :mdelay_reason_twos
  end
end