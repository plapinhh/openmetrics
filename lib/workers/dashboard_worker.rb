class DashboardWorker < BackgrounDRb::MetaWorker
  set_worker_name :dashboard_worker
  #set_no_auto_load true #do not autoload on bdrb start
 
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
    add_periodic_timer(60) { clean_dashboards }     
  end
    
  def clean_dashboards
    # find active sessions
    #sessions = Session.find :all
    
    # delete all dashboards where updated_at and created_at are equal
    temp_dashboards = Dashboard.find :all, :conditions => { :temporary => true }
    
    temp_dashboards.each do |d|
      puts d.inspect
    end
  end
end

