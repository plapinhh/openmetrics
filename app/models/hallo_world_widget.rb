class HalloWorldWidget < Widget

#  TODO cleanup, lots of useless code

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
    if (self.preferences && self.preferences['text'])
      self.preferences['text'] = ActionController::Base.helpers.strip_tags(self.preferences['text'])
    end
  end

  
end
