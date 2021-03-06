module HTMLFormbakery



  public


  def info_for(object)
    attributes = object.attributes
    attributes.each do |attribute|
      puts "Attribute: »#{attribute[0]}« has a value of »#{attribute[1]}« and is a »#{attribute[1].class}«"

      # check for linked subobjects
      if attribute[0][((attribute[0].length)-3)..attribute[0].length].include? "_id"
        puts "    and it is a linked Object"
        # lets see, if we can get info in this too!
        object_class_name = attribute[0][0..((attribute[0].length)-4)]
        puts "    - Classname = #{object_class_name}"
        caller = object_class_name.camelize # make CamelCase
        # TODO Check attribute[1] to be really a FixNum/Integer
        newobj = eval("#{caller}.find(#{attribute[1]})")
        puts " . . subobject: . . "
        self.form_for newobj
        puts " . . . . . . . . . ."
      end

      # serialized data?
      if attribute[1].is_a? Hash
        self.form_for_hash attribute[1]
      end
    end
    puts " "
  end

  # Returns a html-form for the given RAILS-object
  # Possible options:<br/>
  #<br/>
  # :nested - does not create 'form'-tags<br/>
  # :only (array) - only create inputs for the given fields<br/>
  # :except (array) - create all inputs except for the given fields<br/>
  # :include_linked_objects - if set, FB will try to create fields for linked objects too.<br/>
  # :include_join_tables (array) - EXPERIMENTAL include join tables linking to the object in form of lists<br/>
  # <br/>
  # Not implemented:<br/>
  # :include_subobjects<br/>
  # :include_timestamps<br/>
  #
  def htmlform_for(object, *args)
    default_action = "update"
    default_method = "post"
    object_name = object.class.to_s.underscore # makes "RunningService" become "running_service"
    list_only = nil
    list_except = nil
    list_include_join_tables = nil

    # *args is an Array and not a hash, so we need to make it a little more
    # usable first! Scan for known options and use them
    args.each do |args_object|
      if args_object.is_a? Hash

        if args_object.include? :only
          list_only = args_object[:only]
        end

        if args_object.include? :except
          list_except = args_object[:except]
        end

        if args_object.include? :include_join_tables
          list_include_join_tables = args_object[:include_join_tables]
        end

      end
    end

    html_result = ""

    # start the form

    unless args.include? :nested
      html_result += "<form class=\"niceforms\" method=\"#{default_method}\" action=\"/#{object_name.pluralize}/#{object.id}\">"
    end

    addtional_fields = "" # here go the fields for linked subobjects

    attributes = object.attributes
    html_result += "<fieldset>"
    html_result += "<legend>#{object.class.to_s}</legend>"
    attributes.each do |attribute|

      #puts "Attribute: »#{attribute[0]}« has a value of »#{attribute[1]}« and is a »#{attribute[1].class}«"
      unless list_only.nil?
        if list_only.include? attribute[0].to_sym
          html_result += input_for(object_name, attribute[1], attribute[0])
        end
      end

      # except not nil, but (list_only == nil)!
      unless list_except.nil? and list_only.nil?
        unless list_except.include? attribute[0].to_sym
          html_result += input_for(object_name, attribute[1], attribute[0])
        end
      end

      # show all attributes
      if list_only.nil? and list_except.nil?
        html_result += input_for(object_name, attribute[1], attribute[0])
      end

      

      if args.include? :include_linked_objects
        # check for linked subobjects
        if attribute[0][((attribute[0].length)-3)..attribute[0].length].include? "_id"

          # lets see, if we can get info in this too!
          object_class_name = attribute[0][0..((attribute[0].length)-4)]
          #puts "    - Classname = #{object_class_name}"
          caller = object_class_name.camelize # make CamelCase

          newobj = eval("#{caller}.find(#{attribute[1]})")
          #html_result += " . . subobject: . . "
          #html_result += "</fieldset>"
          addtional_fields += self.form_for newobj, true
          #html_result += "<fieldset>"
          #html_result += " . . . . . . . . . ."
        end
      end
      # serialized data?
      if attribute[1].is_a? Hash
        self.form_for_hash attribute[1]
      end
    end
    html_result += "</fieldset>"
    html_result += addtional_fields

    unless list_include_join_tables.nil?
      html_result += join_table_input(object, object_name, list_include_join_tables)
    end
    
    unless args.include? :nested
      html_result += "<fieldset>"
      html_result += "<div style=\"margin: 0pt; padding: 0pt; display: inline;\"><input type=\"hidden\" value=\"put\" name=\"_method\"><input type=\"hidden\" value=\"#{form_authenticity_token}\" name=\"authenticity_token\"></div>"
      html_result += "<input type=\"submit\" value=\"update\" name=\"commit\">"
      html_result += "</fieldset>"
      html_result += "</form>"
    end

    return html_result
  end


  protected
  # TODO: Hash in a Hash in a Hash?!
  def form_for_hash(hashobject)
    hashobject.each do |item|
      if (item.is_a? Array) and (item.size == 2)
        puts "          Serialized Value: »#{item[0]}« value »#{item[1]}« is a »#{item[1].class}«"
      end
    end
  end

  def input_for(formholder_object_name,object,object_name)
    #result = "<p>#{object_name.camelize}: "

    result = "<dl><dt><label for=\"#{formholder_object_name}[#{object_name}]\">#{object_name.camelize}:</label></dt>"
    result += "<dd>"
    if object.is_a? String
      result += "<input type=\"text\" value=\"#{object.to_s}\" name=\"#{formholder_object_name}[#{object_name}]\" id=\"#{formholder_object_name}_#{object_name}\">"
      result += "</dd></dl>"
      return result
    end
    if object.is_a? Fixnum
      # Note: this could be an ID linked to another Object/Objectlist, this could be made a 'select' instead!

      # check if it is an ID_field
      if object_name[((object_name.length)-3)..object_name.length].include? "_id"
        # it is an ID_field
        # We suppose it is a link to another set of Objects, so we obtain a list containing them!
        object_class_name = object_name[0..((object_name.length)-4)]
        caller = object_class_name.camelize # make CamelCase
        list = eval("#{caller}.find(:all, :select => \"name,id\")") # we assume the objects have a 'name'
        result += "<select name=\"[#{object_name}(1i)]\" id=\"#{object_name}_1i\">"
        list.each do |item|
          result += "<option #{"selected=\"selected\"" unless item.id != object} value=\"#{item.id}\">#{item.name}</option>"
        end
        result += "</select>"

      else
        # just a normal Integer!
        result += "<input type=\"text\" value=\"#{object.to_s}\" name=\"#{formholder_object_name}[#{object_name}]\" id=\"#{formholder_object_name}_#{object_name}\">"
      end
      result += "</dd></dl>"
      return result
    end
    if object.is_a? Time
      # usually you wont need to change this, but we can generate an input too:
      # TODO : BROKEN!
      #result += ActionView::Helpers::DateHelper.select_datetime object
      result += "</dd></dl>"
      return result
    end
    result += " unknown object type: #{object.class}"
    result += "</dd></dl>"
    return result
  end

  def join_table_input(object, object_name, tablename)
    linked_objects = eval("#{tablename.camelize}.find(:all, :conditions => { :#{object_name}_id => #{object.id.to_s}})")
    possible_objects = eval("#{tablename.camelize}.find(:all)")

    has_name = false
    object_class_name = ""
    caller = ""
    # has object a name?
    #if linked_objects.first.has_attribute? "name"
    #  has_name = true
    #else
    #  has_name = false
    #end

    possible_objects.first.atrributes.each do |attribute|
      if attribute[0][((attribute[0].length)-3)..attribute[0].length].include? "_id"
        # this is one link from the join table, lets see if it is the right one
        if attribute[0].include? object_name
          # not this name!
        else
          # this one is right! if only two id_links are present... which should be in a join table
          # lets see, if we can get info in this too!
          object_class_name = attribute[0][0..((attribute[0].length)-4)]
          #puts "    - Classname = #{object_class_name}"
          caller = object_class_name.camelize # make CamelCase

          #newobj = eval("#{caller}.find(#{attribute[1]})")
        end
      end
    end

    result = ""
    result += "<select multiple>"
    linked_objects.each do |object|
      name = "unnamed"
      if has_name
        linked_id = 0
        object.attributes.each do |attribute|
          if attribute[0][((attribute[0].length)-3)..attribute[0].length].include? "_id"
            # this is one link from the join table, lets see if it is the right one
            if attribute[0].include? object_name
              # not this name!
            else
              # this one is right! if only two id_links are present... which should be in a join table
              # lets see, if we can get info in this too!
              object_class_name = attribute[0][0..((attribute[0].length)-4)]
              #puts "    - Classname = #{object_class_name}"
              caller = object_class_name.camelize # make CamelCase

              newobj = eval("#{caller}.find(#{attribute[1]})")
            end
          end
        end
        #newobj = eval("#{caller}.find(#{object.})")
      end
      result += "<option value=\"#{object.id}\"> #{object.name if has_name} #{object.id.to_s} </option>"
    end
    result += "</select>"

    result += "<select multiple>"
    possible_objects.each do |object|
      result += "<option value=\"#{object.id}\"> #{object.name  if has_name} #{object.id.to_s} </option>"
    end
    result += "</select>"

    return result
  end

end
