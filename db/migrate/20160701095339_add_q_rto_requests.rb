class AddQRtoRequests < ActiveRecord::Migration
  def self.up
  		add_column :requests, :QR, :string
  end

  def self.down
  		remove_column :requests, :QR
  end
end
