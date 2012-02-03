class AlertWidget < Widget
  # store ui preferences as serialized json
  # http://stackoverflow.com/questions/2959661/rails-serializing-objects-in-a-database
  serialize :preferences



#Allow Children To Use Their Parent’s Routes
#http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
  def self.model_name
    name = "alert_widget"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
    end
    return name
  end

end
