require "test_helper"

class ExampleWidgetTest < Test::Unit::TestCase
  test "a first test" do
    html = widget(:example_widget, :display, 'my_example_widget').invoke
    assert_selekt html, "p"
  end
end
