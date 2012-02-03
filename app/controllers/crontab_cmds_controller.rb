class CrontabCmdsController < ApplicationController
  def index
    @crontab_cmds = CrontabCmd.find(:all)
    @dom = CrontabDaysOfMonth.find(:all)
    @foo = CrontabDaysOfWeek.find(:all)
    @foo = CrontabHour.find(:all)
    @foo = CrontabMin.find(:all)
    @foo = CrontabMonth.find(:all)
    @foo = CrontabJob.find(:all)
    @foo = ServersAndService.find(:all)
    @foo = NagiosSystem.find(:all)
  end
end
