class Alert < ActiveRecord::Base
  belongs_to :system

  # this is used to provide parsable created_at to date.js
  # http://www.ruby-forum.com/topic/158638
  def created_at_js
    created_at.to_s
  end
end
