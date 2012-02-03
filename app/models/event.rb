class Event < ActiveRecord::Base

  def name
    prefs = self.prefs if self.prefs
    ((prefs && prefs['title'].length > 0 && prefs['title']) || (self.id && ("id#"+self.id.to_s)) || "new event")
  end

  def prefs
    ActiveSupport::JSON.decode(self.preferences) if self.preferences
  end
  
end
