require 'ldap'

public 
def ldap_authenticated?(login,password)
  return false if password.blank?
  ldap_host = 'ldaphost.local' #LDAP server IP or fqdn
  ldap_port = 389

  begin
    puts "INFO trying to authenticate by LDAP with #{login}"
    ldap_conn = LDAP::Conn.new(ldap_host, ldap_port)
    ldap_conn.set_option( LDAP::LDAP_OPT_PROTOCOL_VERSION, 3 )
    ad_login = login + "@example.com" #user suffix if needed
    ldap_conn.bind( ad_login, password )
    true
  rescue
    return false
  end  
end

