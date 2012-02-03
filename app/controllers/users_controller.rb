class UsersController < ApplicationController
  before_filter :check_master_role, :except => [ :show, :update, :uploadpubkey, :show_breadcrumbs, :hide_breadcrumbs ]
  filter_parameter_logging "password", "password_confirmation"

   # bounce back (restful auth)
  after_filter :store_location, :only => [:index, :new, :show, :edit]


  # FIXME curretnly used for all the admin area stuff
  def index
    @users = User.find(:all, :order => 'login')

    # TODO move to admin area
    # collectd plugin configuration
    #
    @services = Service.find(:all)
    @services.each do |s|
      # s.type gives deprecation warning, type column is used for sti
      if s.class.name == "CollectdService"
        @collectd_service_available = true
      end
    end

    
    @collectd_plugins = CollectdPlugin.find(:all)
#
#    if @collectd_service_available
#      # all systems with running_services and their attached collectd_plugins
#      puts "\n\nenabled collectd_plugins:\n"
#      systems = System.find :all, :include => [:running_services => :service ]
#      systems.each do |sys|
#        puts "+ #{sys.fqdn} [system_id #{sys.id}]"
#        sys.running_services.each do |rs|
#          puts "+++ #{rs.service.name} [service_id #{rs.service.id}, running_service_id #{rs.id}]"
#          rcps = RunningCollectdPlugin.find :all, :conditions => {:running_service_id => rs.id}, :include => :collectd_plugin
#          rcps.each do |rcp|
#            puts "++++++ #{rcp.collectd_plugin.name} [collectd_plugin_id #{rcp.collectd_plugin.id}]"
#          end
#        end
#      end
#      puts "\n\n\n"
#    end


    #all_worker_info returns a list of array of hashes
    @backgroundrb_worker = MiddleMan.all_worker_info

    
     # get result from backgroudrbs cache store
     # jobkey needs to be unique between:
     # => filename
     # => system
     # => refresh_interval of widget
     #MiddleMan.worker(:logtail_worker, :worker_key => "1stshot")
     @logtail_cacheoutput = MiddleMan.worker(:logtail_worker).ask_result("MAKE_ME_RANDOM")
     #reset memcache
     #MiddleMan.worker(:logtail_worker,"worker_key").reset_memcache_result("MAKE_ME_RANDOM")

    add_breadcrumb('Admin area')

  end # /index

  def show
    @user = User.find(params[:id])
    @recent_scans = IpLookup.find( :all, :conditions => { :user_id => params[:id] }, :order => "created_at DESC", :limit => 5 )
    add_breadcrumb 'Your profile'
  end

  
  def edit
    @user = User.find(params[:id])
  end

  # This is not RESTful and should be refactored in the next CodeReview
  def uploadpubkey
    @user = User.find(@current_user.id)
  end

  # NOT GOOD YET, needs to be sanitized, only for SSH testing now!
  def update
    @user = User.find(params[:id])
    @user.sshpubkey = params[:user][:sshpubkey]
    @user.time_zone = params[:user][:time_zone]
    # FIXME this should prevent users from updating other users profile
    if ( @user.id == @current_user.id || @current_user.has_role?('master') )
      @user.save!
      redirect_back_or_default("/")
      flash[:notice] = "Your profile has been saved!"
    else
      redirect_back_or_default("/")
      flash[:notice] = "Couldn't save profile!!"
    end
  end

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    #logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      #self.current_user = @user # !! now logged in

      redirect_to(users_url)
      flash[:notice] = "New user account created. The user can now log in."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again."
      render :action => 'new'
    end
  end

  def destroy
    @user = User.find(params[:id])

    unless @user.id == @current_user.id
      @user.destroy
    end

    respond_to do |format|

      if @user.id == @current_user.id
        flash[:error] = "You cannot delete yourself while logged in!"
      else
        flash[:notice] = "User has been deleted"
      end
      format.html { redirect_to(users_url) }
    end
  end

  def show_breadcrumbs
    cookies[:breadcrumbs_show] = true
    render :nothing => true
  end
  def hide_breadcrumbs
    cookies[:breadcrumbs_show] = false
    render :nothing => true
  end
    
end
