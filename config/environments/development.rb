# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false


# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false


#Allow Children To Use Their Parent’s Routes
#http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
#%w[widget munin_image_widget].each do |c|
#  require_dependency File.join("app","models","#{c}.rb")
#end
