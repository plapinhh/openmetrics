require 'collectd_preset'
class Dashboard < ActiveRecord::Base
  
  has_many :widgets, :dependent => :destroy
  # nice urls, see http://norman.github.com/friendly_id/file.Guide.html
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true, :ascii_approximation_options => :german

  # creates some widgets
  # TODO cleanup temporary dashboards
  def create_dashboard_for_system (system_id)
    system = System.find(system_id)
    
    self.name = "performance overview for "
    unless system.name == "unnamed"
      self.name << "system #{system.name}"
    else
      self.name << "unnamed system (#{system.id})"      
    end

    self.save

    max_zindex = 0
   
    widget = TextWidget.new()
    widget.dashboard_id = self.id
    text = "[b]" << self.name << "(today, last week, last month)[/b]"
    widget.preferences = 	{'text'=>text, 'bubble' => 'example-obtuse'}
    widget.sizex = 1260
    widget.sizey = 40
    widget.top = 70
    widget.left = 20
    widget.zindex = max_zindex = max_zindex + 1
    widget.save

    top = 130
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
      ["today_range", "lastweek_range", "lastmonth_range"].each {|range|
        widget = CollectdImageWidget.new()

        widget.dashboard_id = self.id
        widget.preferences = {}
        widget.preferences['title'] = preset[0] + ' ' + range.split(/_/).first
        widget.preferences['metric_preset'] = preset[0]
        widget.preferences['metric_value_kind'] = 'average'
        widget.preferences['date_range'] = range
        widget.preferences['system_id'] = ActiveSupport::JSON.encode([system_id])

        widget.sizex = 400
        widget.sizey = 300
        widget.top = top + 30
        widget.left = left
        left = left + 430
        widget.zindex = max_zindex = max_zindex + 1

        widget.save
      }
      top = top + 370
    }

  end

end
