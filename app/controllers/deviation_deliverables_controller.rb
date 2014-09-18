class DeviationDeliverableController < ApplicationController


  def index
    if params[:lifecycle_id] != nil
      @lifecycle_index_select = params[:lifecycle_id]
    else
      @lifecycle_index_select = 1
    end
  end
  
end
