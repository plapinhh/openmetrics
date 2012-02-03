class Widget < ActiveRecord::Base
  
  #attr_accessible :type, :dashboard_id, :top, :left, :sizex, :sizey
  #

  belongs_to :dashboard
  
  # store ui preferences as serialized json
  # http://stackoverflow.com/questions/2959661/rails-serializing-objects-in-a-database
  serialize :preferences


  # STI "type" isn't accessible for to_json, use virt. attribute to do so
  # http://stackoverflow.com/questions/1601739/rails-attr-accessible-does-not-work-for-type
  def get_type
    return self.type
  end

  def get_type=(type)
    self.type = type
  end


  # select for types of widget children
  #http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
  # >> Widget.child_classes
  # => ["MuninImageWidget"]

  # mhhhhh.... doesn't work :(
  #  @child_classes = []
  #  def self.inherited(child)
  #    @child_classes << child
  #    super # important!
  #  end
  #
  #  def self.child_classes
  #    @child_classes
  #  end


end
