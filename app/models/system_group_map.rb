class SystemGroupMap < ActiveRecord::Base
  belongs_to :system
  belongs_to :system_group
end
