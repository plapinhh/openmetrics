class AddOldTables < ActiveRecord::Migration
  def self.up
    create_table :crontab_days_of_month do |t|
      t.integer :crontab_job_id
      t.integer :day_of_month
      t.date :timestamp
      t.boolean :isnew, :default => true

      t.timestamps
    end
    
    create_table :crontab_days_of_week do |t|
      t.integer :crontab_job_id
      t.integer :day_of_week
      t.date :timestamp
      t.boolean :isnew, :default => true
      
      t.timestamps
    end
    
    create_table :crontab_hours do |t|
      t.integer :crontab_job_id
      t.integer :hour
      t.date :timestamp
      t.boolean :isnew, :default => true
      
      t.timestamps
    end
    
    create_table :crontab_mins do |t|
      t.integer :crontab_job_id
      t.integer :min
      t.date :timestamp
      t.boolean :isnew, :default => true
      
      t.timestamps
    end
    
    create_table :crontab_months do |t|
      t.integer :crontab_job_id
      t.integer :month
      t.date :timestamp
      t.boolean :isnew, :default => true
      
      t.timestamps
    end
    
    create_table :crontab_jobs do |t|
      t.integer :crontab_cmd_id
      t.integer :system_id
      t.text :account
      t.text :time_field
      t.date :timestamp
      t.boolean :isnew, :default => true
      
      t.timestamps
    end
    
    create_table :crontab_cmds do |t|
      t.text :command
      
      t.timestamps
    end
    
    create_table :servers_and_services do |t|
      t.text :machine
      t.text :nagios_name
      t.text :nagios_alias
      t.string :ip
      t.text :dns_alias
      t.text :site
      t.text :environment
      t.text :service
      t.text :description
      t.text :data_exchange
      t.text :protocol
      t.text :port
      t.integer :serverid
      t.text :hardware
      t.text :perl_path
      t.text :perl_version
      t.text :perl_arch
      t.text :uname
      t.text :date
      t.text :atanas # great name for the field X-)
      t.text :inventar_no
      t.text :spacenet_cust
      t.text :owner
      t.integer :system_id
      
      t.timestamps
    end
    
    create_table :nagios_systems do |t|
      t.integer :system_id
      t.text :name
      t.text :alias
      t.integer :parent_id
      t.text :contact_groups
      
      t.timestamps
    end
  end

  def self.down
    drop_table :crontab_days_of_month
    drop_table :crontab_days_of_week
    drop_table :crontab_hours
    drop_table :crontab_mins
    drop_table :crontab_months
    drop_table :crontab_jobs
    drop_table :crontab_cmds
    drop_table :servers_and_services
    drop_table :nagios_systems
  end
end
