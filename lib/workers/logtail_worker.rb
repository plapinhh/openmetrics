require 'net/ssh' #this is the whole magic!

# http://backgroundrb.rubyforge.org/files/README.html
class LogtailWorker < BackgrounDRb::MetaWorker
  set_worker_name :logtail_worker
  #set_no_auto_load true #do not autoload on bdrb start
  
  # this method is called, when worker is loaded for the first time
  def create(args = nil) 
    puts "Backgroundrb: logtail_worker created"
    
      # FIXME existing ssh-connections should be reused by multiple worker
      # TODO create UI for overview of all established ssh-session

      # FIXME pass from system_ip   
      host = '127.0.0.1'
      gateway = false
      # FIXME hardcoded ssh creds
      if ENV['RAILS_ENV'] == 'production'
        user = "om"
      else
        user = "mgrobelin"
      end
      # -n0 no previous line output
      command = "tail -f"
      #file = "#{RAILS_HOME}/log/development.log"
      if ENV['RAILS_ENV'] == 'production'
        file = "#{RAILS_HOME}/log/production.log"
      elsif ENV['RAILS_ENV'] == 'development'
        file = "#{RAILS_HOME}/log/development.log"
      end
      # FIXME hardcoded path to ssh key
      keys = [ "/home/om/.ssh/id_rsa"]
      #port = 22
      port = false
      
      # ssh session options
      session_options = { }
      session_options[:port] = port if port
      session_options[:keys] = keys if keys
      #session_options[:verbose] = :debug 

      if gateway
        puts "SSH connect via gateway #{gateway}..."
        gw = Net::SSH::Gateway.new(gateway, user, session_options)
        puts "SSH connect to #{user}@#{host}..."
        @session = gw.ssh(host, user, session_options)
      else
        puts "SSH connect to #{user}@#{host} by logtail_worker"
        @session = Net::SSH.start(host, user, session_options)
      end

      dotail(file)
    
      # http://net-ssh.rubyforge.org/ssh/v2/api/classes/Net/SSH/Connection/Session.html#M000245puts
      puts "SSH processing #{@session}"
      @session.process(0)
  end

  def dotail(file)
    @channels = []
    puts "SSH dotail on #{@session}"
    command="/usr/bin/tail -f -n0"
    @buffer = ""
    # FIXME cleanup created cachefiles
    # INFO --tmpdir only works for coreutils >= 7.4
    #tmpfile = `mktemp --tmpdir=#{RAILS_HOME}/tmp/cache ssh-logtail-buffer.XXXXXX`
    tmpfile = `mktemp -p #{RAILS_HOME}/tmp/cache ssh-logtail-buffer.XXXXXX`

    @session.open_channel do |channel|
      puts "SSH channel opened on #{@session.host}: #{channel}"
      channel.on_data do |ch, data|
        #puts "DEBUG #{ch} STDOUT\n#{data}"
        @buffer << data
#        puts "SSH writing buffer of #{channel} to cachefile: #{tmpfile}"
#        File.open(tmpfile, 'w') do |f|
#          f.puts @buffer
#        end
#
        # INFO memcache currently can't store data >1MB, otherwise this gives
        # protection for heap overflow
        # FIXME memcache key should be random??!
        puts "SSH writing buffer of #{channel} to cache"
        cache["MAKE_ME_RANDOM"] = @buffer  
#        parse_line(data)
      end

      channel.on_open_failed do |ch|
        puts "SSH channel open failed #{channel}"
      end

      channel.on_extended_data do |ch, data|
        puts "DEBUG #{ch} STDERR #{channel}\n#{data}"
      end

      channel.on_close do |ch|
        ch[:closed] = true
      end

      puts "SSH executing #{command} on #{file}"
      channel.exec "#{command} #{file}"
      # we could safe existing ssh session somewhere to reuse connections
      #puts "SSH pushing #{@session.host}\n"
      #@channels.push(channel)
    end

      # loop for as long as there are any channels active, but make sure
      # the event loop runs at least once per 0.1 second
      # http://net-ssh.rubyforge.org/ssh/v2/api/classes/Net/SSH/Connection/Session.html#M000244
      #@session.loop(0.1)
      @session.loop
end


    def parse_line(data)
      @buffer.split("\n").each() do |line|
        # add/convert linebreaks
#        unless line.include? "\n"
#          @buffer = "#{line}"
#          next
#        end
#        line.gsub!(/\n\n/, "\n")
#        line.gsub!(/\n\n/, "\n")
      end

      return @buffer
      @buffer = "" if @buffer.include? "\n"
    end


end

