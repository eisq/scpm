class SessionsController < ApplicationController

  layout 'login'

  def login
    @error = params[:error]
  end

  def do_login
    authenticate(params[:person][:login], params[:person][:pwd])
    if logged_in?
      session[:project_filter_qr] = [current_user.id]
      if not current_user.has_role?('Admin')
        session[:project_sort]      = 'alpha'
      else
        session[:project_sort]      = nil
      end
      redirect_to :controller=>'projects'
      return
    end
    redirect_to :action=>:login, :error=>"Could not log you in"
  end

  def logout
    forget_me
    redirect_to :action=>:login
  end

end
