class BackgroundController < ApplicationController
  layout 'tools'

  # LESSON SHEET ROWS INDEX
  LESSON_BEGIN_HEADER               = 0

  # ------------------------------------------------------------------------------------
  # ACTIONS
  # ------------------------------------------------------------------------------------

  # Index
  def index
    # Params init
  	@linkPicture    = nil
    @saved          = params[:saved]
    if(Background.last)
      @liens = Background.last.url
    end
  end
  
  def save
    # Import excel file
    url         = params[:background]
    if url.to_s.last(4) != ".jpg"
      format_ko = 1
    else 
      format_ko = 0
      @background_action = Background.new(url)
      @background_action.save
    end

    redirect_to(:action=>'index', :format=>format_ko)
  end
end
