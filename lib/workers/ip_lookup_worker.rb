require 'nmap/parser'  # http://rubynmap.sourceforge.net/doc/Nmap/Parser.html


class IpLookupWorker < BackgrounDRb::MetaWorker
  set_worker_name :ip_lookup_worker
  #set_no_auto_load true #do not autoload on bdrb start


  # this method is called, when worker is loaded for the first time
  def create(args = nil)
    puts "INFO IpLookupWorker created"
  end


  # executes a bunch of tests with nmap on a given IPv4 adress
  # TODO scan by SSH, if there is a RunningService "SshService" on that ip
  def scan_services(args)
    puts "DEBUG IpLookupWorker called with args #{args.inspect}"
    #if args[:foo]
    #  puts "DEBUG IpLookupWorker got foo! :D"
    #end

    ip = args[:ip]


    # FIXME cleanup created cachefiles
    tmpfile = ` mktemp --tmpdir=#{RAILS_HOME}/tmp/cache nmap-ip-lookup.xml.XXXXXXXX `

    # create nmap xml report by system call
    puts "INFO IpLookupWorker starting Nmap scan on #{ip}"
    # FIXME sanatize user input; an attacker could pass somthing like " && rm -rf / here" !!!
    nmap_output = ` nmap -oX "#{tmpfile}" -sCV "#{ip}" `
    puts "DEBUG IpLookupWorker nmap output:\n#{nmap_output}\nDEBUG IpLookupWorker /nmap output"


    @result = []
    # parallel parsing of scan result
    callback = proc do |host|
            return if host.status != "up"
            puts "DEBUG IpLookupWorker found #{host.addr}"
            [:tcp, :udp].each do |type|
                host.getports(type, "open") do |port|
                        srv = port.service
                        @result.push(  {:addr => host.addr, :hostnames => host.hostname, :services => srv } )
#                        puts "Port ##{port.num}/#{port.proto} is open (#{port.reason})"
#                        puts "\tService: #{srv.name}" if srv.name
#                        puts "\tProduct: #{srv.product}" if srv.product
#                        puts "\tVersion: #{srv.version}" if srv.version
                end
            end
     end
    parser = Nmap::Parser.new(:callback => callback)
    
    # persist scanresult to database
    j = "#{args[:job_key]}"
    puts "DEBUG IpLookupWorker persisting scanresult"
    if parser.parsefile(tmpfile)
      i = IpLookup.find( :first, :conditions => {:job_key => j} )
      unless i.nil?
        if @result.empty?
          i.scanresult = '["host seems down"]' #json 
        else
          i.scanresult = @result.to_json
        end
        i.save
      end
      # put to result to memcache aswell
      # FIXME if jobkey contains slashes or other characters, memcache may fail
      cache["#{j}"] = @result.to_json
    else
      i = IpLookup.find( :first, :conditions => {:job_key => j} )
      unless i.nil?
        i.scanresult = '["failed"]' #json
        i.save
      end
    end

    # update IpLookup scanresult
  
    puts "INFO IpLookupWorker Nmap scan finished in #{parser.session.scan_time} seconds"
    #process_result
  end

  # TODO add RunningServices, their Service.type could be guessed by camalize nmap output, e.g. http and append "Service"
  # TODO implement Notifications for WEB-UI
  def process_result
    puts "INFO IPLookupWorker starting scan result post processing"

    cache["my_scan_result"] = @result.inspect
    
    # create an IpLookup
    if @result 
      for host in @result
          puts "DEBUG got result #{host.inspect}"
          #puts "INFO creating System for #{host}"
          #s = System.new
          #s.fqdn = host[:hostnames]
          #s.ip = host[:addr]
          #s.description = "added by IpLookupWorker"
          #s.save

        end
    else
      puts "WARN IpLookupWorker failed"
    end

  end





end

