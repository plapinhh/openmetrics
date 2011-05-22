class NotificationWidget < Apotomo::StatefulWidget 
 
  def display
    # http://blip.tv/file/3549867
    # see example_widget for triggering this event by link
    root.respond_to_event :sendNotification, :with => :notify, :on => self.name
    
    render
  end

  def notify
    

    #render :view => :display
 #   render :js => 'jQuery("#workspace").append("foo :) ");'
    render :js => 'notify ("notice", "notice");'

  end
  
end
