def sanitize_object(record)
  protected_attributes = ["id", "created_at", "updated_at"]
  self.attributes.each do |attribute|
    unless ((protected_attributes.include? attribute[0]) or (attribute[1].nil?))
      if attribute[1].is_a?(String)
        attribute[1].gsub!("\"","\\\"") # sanitize quotation
        attribute[1].gsub!("\#{","\#") # sanitize inline ruby, because we use eval
        #
        # ATTENTION: eval is considered dangerous, when not carefully sanitized!
        #
        eval("record.#{attribute[0]}=\"#{ActionController::Base.helpers.strip_tags(attribute[1])}\"")
      end
    end
  end
end