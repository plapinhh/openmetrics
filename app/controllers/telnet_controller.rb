class TelnetController < ApplicationController

  def get_munin_services
    @system = System.find(params[:id])
    @list = ask_munin_at @system.ip

    respond_to do |format|
      format.json  {
          @json_export = ""
          @json_export << "{"
          @json_export <<   '"MuninServices":'
          ActiveRecord::Base.include_root_in_json = false
          @json_export <<       @list.to_json()
          ActiveRecord::Base.include_root_in_json = true
          @json_export << "}" #end @json_export
          render :text => @json_export
      }
    end
  end
  
end
