class SystemHistory < ActiveRecord::Base


  # using the parameter system as template, this method sets the
  # current SystemHistory Object as a carbon copy of system.
  def take_snapshot(system)
    
    # we dont need to copy those:
    protected_attributes = ["created_at", "updated_at", "id"]

    attributes_for_update = Hash.new

    # we go through all attributes and copy them here
    # attribute[0] is the name of the attribute, whereas attribute[1] is the value
    system.attributes.each do |attribute|
      unless protected_attributes.include? attribute[0]
        if self.attributes.has_key? attribute[0]
          attributes_for_update[attribute[0]] = attribute[1]
        else
          # This should never happen!
          raise "FATAL: unknown attribute found: #{attribute[0]}, your history table is out-of-sync with the real one. Perhaps you forgot to migrate?"
        end
      end
    end

    # not done yet! We still need the timestamps and the id!
    self.system_id = system.id
    
    self.running_from = system.updated_at
    
    # this one is history since NOW!
    self.running_to = DateTime.now

    #self.user_id = user_id

    self.update_attributes(attributes_for_update)
  end

end