# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  skip_before_filter :login_required
  layout "application", :only => :destroy
  layout "login", :only => :new
  filter_parameter_logging "password"

  # render user-login form app/views/sessions/new.html.erb
  # there is a custom layout too - app/views/layouts/login.html.erb
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])

    # if user is nil, we try LDAP authentication
    if !user
      user = User.ldap_authenticate(params[:login], params[:password])
    end

    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      # restore breadcrumbs from cookie & redirect
      # TODO redirecting to last breadcrumb should be configurable within ui
      if (cookies[:breadcrumbs])
        session[:breadcrumbs] = JSON.parse(Base64.decode64(cookies[:breadcrumbs])) 
        last_breadcrumb = session[:breadcrumbs].last
        redirect_to "#{last_breadcrumb[2]}"
      else
        redirect_back_or_default('/')
      end
      flash[:notice] = "Logged in successfully"
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      #render :action => 'new'
      redirect_to login_url
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Could not log you in as »#{params[:login]}«"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
