class CreateSdpConstants < ActiveRecord::Migration
  def self.up
    create_table :sdp_constants do |t|
      t.string :constant_name
      t.float :constant_value
      t.string :constant_comment
      t.timestamps
    end
    SdpConstant.create :constant_name => 'NB_QR' , :constant_value => 24 , :constant_comment => ''
    SdpConstant.create :constant_name => 'NB_FTE' , :constant_value => 20 , :constant_comment => '# TODO: should be automatically calculated from workloads'
    SdpConstant.create :constant_name => 'NB_DAYS_PER_MONTH' , :constant_value => 18 , :constant_comment => ''
    SdpConstant.create :constant_name => 'MEETINGS_LOAD_PER_MONTH' , :constant_value => 1 , :constant_comment => ''
    SdpConstant.create :constant_name => 'PM_LOAD_PER_MONTH' , :constant_value => 48 , :constant_comment => '#was: NB_DAYS_PER_MONTH*2 + NB_DAYS_PER_MONTH/1.5 # CP + PMO + DP'
    SdpConstant.create :constant_name => 'WP_LEADERS_DAYS_PER_MONTH' , :constant_value => 12 , :constant_comment => '#was: 18 # 10 + 4*2'
    
    SdpConstant.create :constant_name => 'PM_PROVISION_ADJUSTMENT' , :constant_value => -157.750 , :constant_comment => ''
    SdpConstant.create :constant_name => 'QA_PROVISION_ADJUSTMENT' , :constant_value => 4 , :constant_comment => ''
    SdpConstant.create :constant_name => 'RK_PROVISION_ADJUSTMENT' , :constant_value => -26.5 , :constant_comment => ''
    SdpConstant.create :constant_name => 'CI_PROVISION_ADJUSTMENT' , :constant_value => -10.125 , :constant_comment => ''
    SdpConstant.create :constant_name => 'OP_PROVISION_ADJUSTMENT' , :constant_value => -75.750 , :constant_comment => ''
  end

  def self.down
    drop_table :sdp_constants
  end
end