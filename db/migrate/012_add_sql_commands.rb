class AddSqlCommands < ActiveRecord::Migration
  def self.up
   
    # secure that created_at and updated_at are always filled
    %w{systems services running_services}.each do |table|
      execute "ALTER TABLE #{table} ALTER COLUMN created_at SET DEFAULT 'now'"
      execute "ALTER TABLE #{table} ALTER COLUMN updated_at SET DEFAULT 'now'"
    end
    
    # add history rules here:
    
    # history_push for systems RULE
    execute "CREATE OR REPLACE RULE history_push AS
               ON UPDATE TO systems DO  
                 INSERT INTO system_histories (
                   name, ip, site, environment, operating_system, 
                   operating_system_flavour, description, responsible, 
                   system_id, running_from, running_to, created_at) 
                 VALUES (
                   old.name, old.ip, old.site, old.environment, old.operating_system, 
                   old.operating_system_flavour, old.description, old.responsible, 
                   old.id, old.updated_at, new.updated_at, now());"
    # history_on_delete for systems RULE
    execute "CREATE OR REPLACE RULE history_on_delete AS
               ON DELETE TO systems DO  INSERT INTO system_histories (name, ip, site, environment, operating_system, operating_system_flavour, description, responsible, system_id, running_from, running_to, created_at) 
               VALUES (old.name, old.ip, old.site, old.environment, old.operating_system, old.operating_system_flavour, old.description, old.responsible, old.id, old.updated_at, now(), now());"
    # history_push for services RULE
    execute "CREATE OR REPLACE RULE history_push AS
             ON UPDATE TO services DO  INSERT INTO service_histories (name, typ, \"group\", description, service_id, running_from, running_to, created_at) 
             VALUES (old.name, old.typ, old.\"group\", old.description, old.id, old.updated_at, new.updated_at, now());"
    # history_on_delete for services RULE
    execute "CREATE OR REPLACE RULE history_on_delete AS
             ON DELETE TO services DO  INSERT INTO service_histories (name, typ, \"group\", description, service_id, running_from, running_to, created_at) 
             VALUES (old.name, old.typ, old.\"group\", old.description, old.id, old.updated_at, now(), now());"
    # history_push for running_services RULE
    execute "CREATE OR REPLACE RULE history_push AS
             ON UPDATE TO running_services DO  INSERT INTO running_service_histories (system_id, service_id, \"comment\", running_service_id, running_from, running_to, created_at, logtype) 
             VALUES (old.system_id, old.service_id, old.\"comment\", old.id, old.updated_at, new.updated_at, now(), 'CHANGE'::character varying);"
    # history_on_delete for running_services RULE
    execute "CREATE OR REPLACE RULE history_on_delete AS
             ON DELETE TO running_services DO  INSERT INTO running_service_histories (system_id, service_id, \"comment\", running_service_id, running_from, running_to, created_at, logtype) 
             VALUES (old.system_id, old.service_id, old.\"comment\", old.id, old.updated_at, now(), now(), 'DELETE'::character varying);"
    # history_on_create for running_services RULE
    execute "CREATE OR REPLACE RULE \"onCreate\" AS
             ON INSERT TO running_services DO  INSERT INTO running_service_histories (system_id, service_id, \"comment\", running_service_id, running_from, running_to, created_at, logtype) 
             VALUES (new.system_id, new.service_id, new.\"comment\", currval('running_services_id_seq'::regclass), new.created_at, now(), now(), 'CREATE'::character varying);"
  end # self.up

  def self.down
  end
end
