class RunningService < ActiveRecord::Base
  belongs_to :system
  belongs_to :service

  # History before_filter set
  def before_update
    # note: 'self' has already changed here! We need the DB Version again!
    RunningServiceHistory.new.take_snapshot(RunningService.find self.id)
  end

  def before_destroy
    RunningServiceHistory.new.take_snapshot(RunningService.find self.id)
  end
  # /History before_filter set

end
