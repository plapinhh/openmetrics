class ApiKeysController < ApplicationController

  before_filter :login_from_cookie
  before_filter :login_required

  # Create or re-generate the API key
  def create
    current_user.enable_api!

    respond_to do |format|
      format.html {
        gflash :success => "Key successfully generated!"
        redirect_back_or_default('/')
      }
    end
  end

  # Delete the API key
  def destroy
    current_user.disable_api!

    respond_to do |format|
      format.html {
        gflash :success => "Key removed!"
        redirect_back_or_default('/')
      }
    end
  end



end
