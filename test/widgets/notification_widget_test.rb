require "test_helper"

class NotificationWidgetTest < Test::Unit::TestCase
  test "a first test" do
    html = widget(:notification_widget, :display, 'my_notification_widget').invoke
    assert_selekt html, "p"
  end
end
