class SdpConstantsController < ApplicationController

  layout 'tools'

  def index
    all
  end
  
  def all
    @constants = SdpConstant.find(:all)
     render(:layout=>'tools')
  end
  
  def edit
    id        = params[:id]
    @constant_sdp = SdpConstant.find(id)
 end
  
  def update
    constant_sdp = SdpConstant.find(params[:id])
    constant_sdp.update_attributes(params[:constant_sdp])
    redirect_to :action=>:index
 end
 
end
