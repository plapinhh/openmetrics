require 'digest/sha1'
require 'ldap_conn'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validates_format_of       :sshpubkey,:with => /^ssh-... .*== .*/i, 
                                       :message => "Your pubkey is formatted wrong, please try again!",
                                       :allow_blank => true


  has_many :permissions
  has_many :roles, :through => :permissions

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :sshpubkey, :time_zone



  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Authenticate against LDAP. Use with care, only call this method, when
  # normal login fails!
  #
  def self.ldap_authenticate(login, password)
    return nil if login.blank? || password.blank?
    # Allow 'classic' login method
    #if find_by_login(login)
    #  return User.authenticate(login, password)

    # checks whether a local user exists, prevents any ldap user from login
    if u = find_by_login(login)
      return (ldap_authenticated?(login, password) ? u : nil)
    else
      return nil
    end

  end

  # Checks if the user has given role assigned to him
  #
  def has_role?(rolename)
   self.roles.find_by_rolename(rolename) ? true : false
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # API stuff from http://www.justinbritten.com/work/2009/05/rails-api-authentication-using-restful-authentication/
  def enable_api!
    self.generate_api_key!
  end

  def disable_api!
    #self.update_attribute(:api_key, "")
    self.update_attribute(:api_key, nil)
  end

  def api_is_enabled?
    !self.api_key.nil?
  end





  protected

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def generate_api_key!
    self.update_attribute(:api_key, secure_digest(Time.now, (1..10).map{ rand.to_s }))
  end

    
  def validate_pubkey_format

  end

end
