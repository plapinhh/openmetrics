# holds results of nmap lookup and the user that initiated the scan
class IpLookup < ActiveRecord::Base
  belongs_to :user
  # scanresult is json
end
