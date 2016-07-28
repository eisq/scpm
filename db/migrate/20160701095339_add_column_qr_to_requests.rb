class AddColumnQrToRequests < ActiveRecord::Migration
  def self.up
  		add_column :requests, :qr, :string
  end

  def self.down
  		remove_column :requests, :qr
  end
end
