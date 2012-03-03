require 'collectd_preset'

class Dashboard < ActiveRecord::Base
  
  has_many :widgets, :dependent => :destroy
  belongs_to :user
  # nice urls, see http://norman.github.com/friendly_id/file.Guide.html
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true, :ascii_approximation_options => :german

  # creates some widgets for a given system aka. performance overview
  # creates a temporary dashboard that is deleted after user has been logged out
  def create_performance_overview (system_id, user)
    self.temporary = true
    self.user_id = user.id
    system = System.find(system_id)
    
    self.name = ""
    unless system.name == "unnamed"
      self.name << "#{system.name}"
    else
      self.name << "system##{system.id}"      
    end

    self.save
   
    max_zindex = 0
   
    widget = TextWidget.new()
    widget.dashboard_id = self.id
    text = "[b]Performance overview for " << self.name << "[/b]"
    widget.preferences = 	{'text'=>text, 'bubble' => ''}
    widget.sizex = 1040
    widget.sizey = 40
    widget.top = 80
    widget.left = 20
    widget.zindex = max_zindex = max_zindex + 1
    widget.save

    top = 180
    CollectdPreset.create.get_all_presets.each {|preset|
      left = 20

      widget = TextWidget.new()
      widget.dashboard_id = self.id
      text = "[b]" << preset[0] << "[/b]"
      widget.preferences = 	{'text'=>text,'bubble' => 'triangle-right'}
      widget.sizex = 400
      widget.sizey = 40
      widget.top = top
      widget.left = 20
      widget.zindex = max_zindex = max_zindex + 1
      widget.save
      top = top + 40
      ["today_range", "lastweek_range"].each {|range|
        widget = CollectdImageWidget.new()

        widget.dashboard_id = self.id
        widget.preferences = {}
        widget.preferences['title'] = preset[0] + ' ' + range.split(/_/).first
        widget.preferences['metric_preset'] = preset[0]
        widget.preferences['metric_value_kind'] = 'average'
        widget.preferences['date_range'] = range
        widget.preferences['system_id'] = ActiveSupport::JSON.encode([system_id])

        widget.sizex = 500
        widget.sizey = 300
        widget.top = top + 30
        widget.left = left
        left = left + 540
        widget.zindex = max_zindex = max_zindex + 1

        widget.save
      }
      top = top + 370
    }

  end

end
