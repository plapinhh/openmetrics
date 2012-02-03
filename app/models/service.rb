class Service < ActiveRecord::Base
  has_many :running_services
  has_many :collectd_plugins

   # History before_filter set
  def before_update
    # note: 'self' has already changed here! We need the DB Version again!
    ServiceHistory.new.take_snapshot(Service.find self.id)
  end

  def before_destroy
    # TODO related running_services needs to be destroyed as well
    ServiceHistory.new.take_snapshot(Service.find self.id)
  end
  # /History before_filter set


  def systems_running_service
    running_services = RunningService.find(:all, :conditions => { :service_id => self.id})
    systems = Hash.[]
      if running_services != nil
        for rs in running_services
          system = nil
          system = System.find_by_id(rs.system_id, :include =>  :running_services ) unless rs.system_id == nil
          if (system != nil)
            systems[rs.id] = system
          end
        end
      end  
    return systems
  end

  # STI "type" isn't accessible for to_json, use virt. attribute to do so
  # http://stackoverflow.com/questions/1601739/rails-attr-accessible-does-not-work-for-type
  def get_type
    return self.type
  end

  def get_type=(type)
    self.type = type
  end
  
end
