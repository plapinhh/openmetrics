require 'test_helper'

class WidgetTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Widget.new.valid?
  end
end
