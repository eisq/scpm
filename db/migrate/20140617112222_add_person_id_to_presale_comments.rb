class AddPersonIdToPresaleComments < ActiveRecord::Migration
  def self.up
    add_column :presale_comments, :person_id, :text
  end

  def self.down
    remove_column :presale_comments, :person_id
  end
end
