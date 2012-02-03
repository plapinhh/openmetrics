require 'net/telnet' #this is the whole magic!

module TelnetAutomagick

    public
    # Opens up a Telnet connection on port 4949 (munin-telnet)
    # and gets the list of monitored services from that system.
    #
    # returns a simple array with each service as string
    #
    def ask_munin_at(server)

        # NOTE: the regex for "Prompt" is a hack, because munin does not
        # send a correct termination character on the 'list' command
        host = Net::Telnet::new("Host" => server,
                                "Port" => 4949,
                                "Prompt" => /^[^#]*.\n/n)

        # get the service list from munin
        response = host.cmd("list")

        # get the second line of the result, which is the line we want
        list = response.each_line.to_a[1]

        # prepare the list as array
        result = list.split.to_a

        host.close # required

        # sort alphabetically
        result.sort! { |a,b| a <=> b }

        return result
    end

end