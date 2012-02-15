# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120210202059) do

  create_table "alerts", :force => true do |t|
    t.integer  "system_id"
    t.string   "metric_identifier"
    t.float    "value"
    t.float    "warning_min"
    t.float    "warning_max"
    t.float    "failure_min"
    t.float    "failure_max"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "severity"
  end

  create_table "bdrb_job_queues", :force => true do |t|
    t.text     "args"
    t.string   "worker_name"
    t.string   "worker_method"
    t.string   "job_key"
    t.integer  "taken"
    t.integer  "finished"
    t.integer  "timeout"
    t.integer  "priority"
    t.datetime "submitted_at"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "archived_at"
    t.string   "tag"
    t.string   "submitter_info"
    t.string   "runner_info"
    t.string   "worker_key"
    t.datetime "scheduled_at"
  end

  create_table "collectd_plugins", :force => true do |t|
    t.string   "name"
    t.text     "configuration"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crontab_cmds", :force => true do |t|
    t.text     "command"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crontab_days_of_month", :force => true do |t|
    t.integer  "crontab_job_id"
    t.integer  "day_of_month"
    t.date     "timestamp"
    t.boolean  "isnew",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crontab_days_of_week", :force => true do |t|
    t.integer  "crontab_job_id"
    t.integer  "day_of_week"
    t.date     "timestamp"
    t.boolean  "isnew",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crontab_hours", :force => true do |t|
    t.integer  "crontab_job_id"
    t.integer  "hour"
    t.date     "timestamp"
    t.boolean  "isnew",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crontab_jobs", :force => true do |t|
    t.integer  "crontab_cmd_id"
    t.integer  "system_id"
    t.text     "account"
    t.text     "time_field"
    t.date     "timestamp"
    t.boolean  "isnew",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crontab_mins", :force => true do |t|
    t.integer  "crontab_job_id"
    t.integer  "min"
    t.date     "timestamp"
    t.boolean  "isnew",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "crontab_months", :force => true do |t|
    t.integer  "crontab_job_id"
    t.integer  "month"
    t.date     "timestamp"
    t.boolean  "isnew",          :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dashboards", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cached_slug"
    t.boolean  "temporary",   :default => false
  end

  add_index "dashboards", ["cached_slug"], :name => "index_dashboards_on_cached_slug", :unique => true

  create_table "events", :force => true do |t|
    t.datetime "start_at"
    t.datetime "end_at"
    t.text     "systems"
    t.text     "services"
    t.text     "systemGroups"
    t.text     "serviceGroups"
    t.text     "preferences"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_items", :force => true do |t|
    t.integer  "system_id"
    t.string   "owner"
    t.date     "contract_start_date"
    t.date     "minimum_contract_running_date"
    t.string   "initial_cost"
    t.string   "monthly_cost"
    t.string   "inv_id_parship"
    t.string   "inv_id_provider"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ip_lookups", :force => true do |t|
    t.integer  "user_id"
    t.text     "scanresult"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "job_key"
    t.string   "target"
  end

  create_table "metrics", :force => true do |t|
    t.string   "group"
    t.string   "plugin"
    t.string   "ds"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metrics_systems", :id => false, :force => true do |t|
    t.integer "system_id"
    t.integer "metric_id"
  end

  add_index "metrics_systems", ["metric_id", "system_id"], :name => "index_metrics_systems_on_metric_id_and_system_id", :unique => true

  create_table "nagios_systems", :force => true do |t|
    t.integer  "system_id"
    t.text     "name"
    t.text     "alias"
    t.integer  "parent_id"
    t.text     "contact_groups"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "rolename"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "running_collectd_plugins", :force => true do |t|
    t.integer  "collectd_plugin_id"
    t.integer  "running_service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "running_service_histories", :force => true do |t|
    t.integer  "system_id"
    t.integer  "service_id"
    t.integer  "running_service_id"
    t.datetime "running_from"
    t.datetime "running_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comment"
    t.string   "logtype"
    t.integer  "last_change_user_id"
  end

  create_table "running_services", :force => true do |t|
    t.integer  "system_id"
    t.integer  "service_id"
    t.string   "comment"
    t.datetime "created_at",          :default => '2010-08-10 17:11:35'
    t.datetime "updated_at",          :default => '2010-08-10 17:11:35'
    t.integer  "last_change_user_id"
  end

  create_table "servers_and_services", :force => true do |t|
    t.text     "machine"
    t.text     "nagios_name"
    t.text     "nagios_alias"
    t.string   "ip"
    t.text     "dns_alias"
    t.text     "site"
    t.text     "environment"
    t.text     "service"
    t.text     "description"
    t.text     "data_exchange"
    t.text     "protocol"
    t.text     "port"
    t.integer  "serverid"
    t.text     "hardware"
    t.text     "perl_path"
    t.text     "perl_version"
    t.text     "perl_arch"
    t.text     "uname"
    t.text     "date"
    t.text     "atanas"
    t.text     "inventar_no"
    t.text     "spacenet_cust"
    t.text     "owner"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_histories", :force => true do |t|
    t.string   "name"
    t.string   "typ"
    t.string   "group"
    t.string   "description"
    t.integer  "service_id"
    t.datetime "running_from"
    t.datetime "running_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dns_name"
    t.integer  "last_change_user_id"
    t.string   "type"
  end

  create_table "services", :force => true do |t|
    t.string   "name"
    t.string   "typ"
    t.string   "group"
    t.string   "description"
    t.datetime "created_at",          :default => '2010-08-10 17:11:35'
    t.datetime "updated_at",          :default => '2010-08-10 17:11:35'
    t.string   "dns_name"
    t.integer  "last_change_user_id"
    t.string   "type"
  end

  create_table "slugs", :force => true do |t|
    t.string   "name"
    t.integer  "sluggable_id"
    t.integer  "sequence",                     :default => 1, :null => false
    t.string   "sluggable_type", :limit => 40
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "slugs", ["name", "sluggable_type", "sequence", "scope"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
  add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"

  create_table "system_group_maps", :force => true do |t|
    t.integer  "system_group_id"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "system_histories", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.string   "environment"
    t.string   "operating_system"
    t.string   "operating_system_flavour"
    t.string   "description"
    t.string   "sshuser"
    t.datetime "running_from"
    t.datetime "running_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "system_id"
    t.string   "munin_group"
    t.integer  "last_change_user_id"
    t.string   "fqdn"
  end

  create_table "system_variables", :force => true do |t|
    t.string   "name"
    t.string   "value"
    t.integer  "system_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "systems", :force => true do |t|
    t.string   "name"
    t.string   "ip"
    t.string   "environment"
    t.string   "operating_system"
    t.string   "operating_system_flavour"
    t.string   "description"
    t.string   "sshuser"
    t.datetime "created_at",               :default => '2010-08-10 17:11:35'
    t.datetime "updated_at",               :default => '2010-08-10 17:11:35'
    t.text     "munin_group"
    t.integer  "last_change_user_id"
    t.string   "fqdn"
  end

  create_table "thresholds", :force => true do |t|
    t.string   "metric_identifiers"
    t.string   "metric_filter"
    t.float    "failure_max"
    t.float    "failure_min"
    t.float    "warning_max"
    t.float    "warning_min"
    t.boolean  "invert_values"
    t.boolean  "percentage"
    t.boolean  "persist"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "system_filter_ids"
    t.string   "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 40
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            :limit => 40
    t.datetime "remember_token_expires_at"
    t.text     "sshpubkey"
    t.string   "api_key",                   :limit => 40
    t.string   "time_zone"
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "widgets", :force => true do |t|
    t.integer  "dashboard_id"
    t.integer  "top"
    t.integer  "left"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sizex"
    t.integer  "sizey"
    t.string   "type"
    t.text     "preferences"
    t.integer  "zindex"
  end

end
