class WelcomePageController < ApplicationController
  #layout "welcome_page"
  layout "application"

  def display

    add_breadcrumb 'Home'

    # some playoaround with workers
    # http://backgroundrb.rubyforge.org/manual/BackgrounDRb/MasterWorker.html
    #@output = MiddleMan.worker(:my_first_logtail).logtail(:arg => current_customer.id)
    #MiddleMan.worker(:my_first_logtail).logtail(:arg => current_customer.id)

    #puts "new worker is going to be created"
    #job1_key = MiddleMan.new_worker(:worker => :logtail_worker, :worker_key => "job_key_1")
#    job2 = MiddleMan.new_worker(:worker => :logtail_worker, :worker_key => "job_key_2")
    #puts "worker_key: #{job1_key}"

    
    #foo = MiddleMan.worker(:logtail_worker).async_logtail

    #puts foo
    #worker = MiddleMan.worker(:logtail_worker, :worker_key => "job_key_1").async_logtail

    respond_to do |format|
        format.html
    end




  end

end
