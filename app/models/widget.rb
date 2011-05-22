class Widget < ActiveRecord::Base
  #attr_accessible :workspace_id, :top, :left, :sizex, :sizey
  belongs_to :workspace

  # Make The Parent Class Aware of Its Children
  # http://code.alexreisner.com/articles/single-table-inheritance-in-rails.html
  def self.select_options
    subclasses.map{ |c| c.to_s }.sort
  end


  @child_classes = []

  def self.inherited(child)
    @child_classes << child
    super # important!
  end

  def self.child_classes
    @child_classes
  end



end
