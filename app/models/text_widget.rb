class TextWidget < Widget

#  BBCode implementation for Ruby
#  http://bb-ruby.rubyforge.org/
#  require 'bb-ruby'

  before_save :strip_html

  # store ui preferences as serialized json
  # http://stackoverflow.com/questions/2959661/rails-serializing-objects-in-a-database
  serialize :preferences


#Allow Children To Use Their Parent’s Routes
#http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
  def self.model_name
    name = "text_widget"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
    end
    return name
  end

protected

  def strip_html
#    :preferences.each do |key, value|
#      :preferences[key] = ActionController::Base.helpers.strip_tags(value)
#    end
    if (self.preferences && self.preferences['text'])
      logger.info self.preferences['text']
      self.preferences['text'] = ActionController::Base.helpers.strip_tags(self.preferences['text'])
#      self.preferences['text'] = BBRuby.to_html(self.preferences['text'])
    end
  end

  
end
