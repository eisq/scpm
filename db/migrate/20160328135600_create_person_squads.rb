class CreatePersonSquads < ActiveRecord::Migration
  def self.up
    create_table :person_squads do |t|
      t.integer :person_id
      t.integer :squad_id
      t.timestamps
    end
  end

  def self.down
    drop_table :person_squads
  end
end