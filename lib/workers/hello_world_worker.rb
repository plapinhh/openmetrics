# this worker will generate a counter and writes result to memcache


# http://backgroundrb.rubyforge.org/files/README.html
class HelloWorldWorker < BackgrounDRb::MetaWorker
  set_worker_name :hello_world_worker
  set_no_auto_load true #do not autoload on bdrb start

  def create
    # this method is called, when worker is loaded for the first time
    puts "Backgroundrb: hello_world_worker created"
    # save buffer on given interval to memcache
    # time argument is in seconds
    @counter = 0
    add_periodic_timer(2) { increment_counter }
  end

  def increment_counter
    @counter += 1
    cache["some_key"] = @counter
  end
  
end

