class CollectdService < Service

#Allow Children To Use Their Parent’s Routes
#http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
  def self.model_name
    name = "collectd_service"
    name.instance_eval do
      def plural;   pluralize;   end
      def singular; singularize; end
    end
    return name
  end


end