class SshPubkeyAdeptController < ApplicationController

    before_filter :check_master_role  # only the master should be able to do this 
                                      # for now
                                      
  
  def deploykey
    @system = System.find(params[:system_id])

    @user = User.find(params[:user_id])

    flash.now[:notice] = deploy_key(@system.ip, @user.sshpubkey)

    #puts flash[:notice]

    #redirect_back_or_default("/")

  end

  def removekey

    @system = System.find(params[:system_id])

    @user = User.find(params[:user_id])

    flash[:notice] = remove_key(@system.ip, @user.sshpubkey)

    #redirect_back_or_default("/")

  end



end
