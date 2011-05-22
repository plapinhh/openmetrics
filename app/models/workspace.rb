class Workspace < ActiveRecord::Base
  attr_accessible :name, :widgets_attributes
  has_many :widgets, :dependent => :destroy
  accepts_nested_attributes_for :widgets, :allow_destroy => true
end
