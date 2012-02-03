# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include AuthenticatedSystem
  include SSHAutomagick
  include TelnetAutomagick
  include HTMLFormbakery

  
  #TIMEOUT CODE
  before_filter :login_required
  before_filter :session_expiry, :except => [:login, :logout]
  before_filter :update_activity_time, :except => [:login, :logout]
  before_filter :set_user_time_zone

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '65c3f4485ccb562a0f8266811b8a8ca9'




  #def render(*args)
  #    args.first[:layout] = false if request.xhr? and args.first[:layout].nil?
  #  super
  #end



protected

  # from http://railscasts.com/episodes/106-time-zones-in-rails-2-1
  def set_user_time_zone
    Time.zone = current_user.time_zone if logged_in?
  end



  #TIMEOUT CODE
  def session_expiry
    unless session[:expires_at].nil?
      @time_left = (session[:expires_at] - Time.now).to_i
      unless @time_left > 0
        logout_killing_session!
        flash[:error] = 'Your session has expired and was closed for security reasons. Please, login again to continue.'
        if request.xhr?
          render :text => 'expired', :status=>"278"
        else 
          redirect_to login_url
        end

      end
    end
  end

  def update_activity_time
    session[:expires_at] = 20.minutes.from_now
    #session[:expires_at] = 10.seconds.from_now
  end

  # adds entry to user session which is displayed in web UI breadcumb bar
  # number of entries is limited
  #
  # arguments
  # name => link text for breadcrumb entry
  # controller_name => text to complete the title-tag phrase "Go to controller_name name", defaults to nil
  # url => href, defaults to request.url
  def add_breadcrumb name, controller_name = nil, url = request.url
    if !request.get? or request.xhr?
      return
    end
    session[:breadcrumbs] ||= []
    url = eval(url) if url =~ /_path|_url|@/
    if session[:breadcrumbs].size > 8
      session[:breadcrumbs].shift
    end
    session[:breadcrumbs] << [name, controller_name, url] if !session[:breadcrumbs].last or (session[:breadcrumbs].last and session[:breadcrumbs].last[2].to_s != url)
    # breadcrumbs are persisted to cookie aswell, to have them available after relogin
    # => base64 encoded json structure
    cookies[:breadcrumbs] = Base64.encode64(session[:breadcrumbs].to_json)
  end

  # redirect if friendly url is available, http://doblock.com/articles/seo-friendly-urls-for-your-rails-app-with-friendly_id
  def enforce_friendly_url_for(object)
    redirect_to object, :status => :moved_permanently unless object.friendly_id_status.best?
  end

end
