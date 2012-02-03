class DropOldDbRules < ActiveRecord::Migration
  def self.up
#    execute "DROP RULE history_on_delete on running_services;"
#    execute "DROP RULE history_push on running_services;"
#    execute "DROP RULE \"onCreate\" on running_services;"
#
#    execute "DROP RULE history_on_delete on systems;"
#    execute "DROP RULE history_push on systems;"
#
#    execute "DROP RULE history_on_delete on services;"
#    execute "DROP RULE history_push on services;"
  end

  def self.down
  end
end
