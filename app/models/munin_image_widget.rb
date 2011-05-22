class MuninImageWidget < Widget

 #Allow Children To Use Their Parent’s Routes
 #http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
def self.model_name
  name = "munin_image_widget"
  name.instance_eval do
    def plural;   pluralize;   end
    def singular; singularize; end
  end
  return name
end

end
