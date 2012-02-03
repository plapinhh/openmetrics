class SearchController < ApplicationController
  
#  search_path() #=> /fish
#  new_search_instance_path() #=> /fish/new
#  search_instance_path(1) #=> /fish/1
#  edit_search_instance_path(1) #=> /fish/1;edit

  def index
    @search_string = params[:search].strip if params[:search]

    limit = 3 if false

    if @search_string != nil

      query = "%" + @search_string + "%"

      @systems = System.find(:all, :limit=>limit, :conditions => [ "(name ILIKE ?) OR (ip ILIKE ?) OR (fqdn ILIKE ?) OR (description ILIKE ?)", query, query, query, query ])

      @services = Service.find(:all, :limit=>limit, :conditions => [ "(name ILIKE ?) OR (dns_name ILIKE ?) OR (typ ILIKE ?) OR (description ILIKE ?)", query, query, query, query ])

      @dashboards = Dashboard.find(:all, :limit=>limit, :conditions => [ "(name ILIKE ?) ", query ])
      
      @events = Event.find(:all, :limit=>limit, :conditions => [ "(preferences ILIKE ?)", query ])
    end

    if request.xhr?
        render :layout => false, :action => 'index_ajax.html.erb'
    end

  end
  
end
