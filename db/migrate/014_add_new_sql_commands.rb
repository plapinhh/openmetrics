class AddNewSqlCommands < ActiveRecord::Migration
  def self.up
    
    # since we changed service-model in the previous migration, we have to 
    # update the RULES, and the history model now
    
    add_column :service_histories, :dns_name, :string
    
    # history_push for services RULE
    execute "CREATE OR REPLACE RULE history_push AS
             ON UPDATE TO services DO  INSERT INTO service_histories (name, typ, \"group\", description, dns_name, service_id, running_from, running_to, created_at) 
             VALUES (old.name, old.typ, old.\"group\", old.description, old.dns_name, old.id, old.updated_at, new.updated_at, now());"
    # history_on_delete for services RULE
    execute "CREATE OR REPLACE RULE history_on_delete AS
             ON DELETE TO services DO  INSERT INTO service_histories (name, typ, \"group\", description, dns_name, service_id, running_from, running_to, created_at) 
             VALUES (old.name, old.typ, old.\"group\", old.description, old.dns_name, old.id, old.updated_at, now(), now());"
  end

  def self.down
  end
end
