require 'test_helper'

class WorkspaceTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Workspace.new.valid?
  end
end
