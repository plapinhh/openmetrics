# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_workspace_example_session',
  :secret      => '53f03de78d34e2ba837fa9146eed17c5bf905ced69ed7b5d24610ab46f929026df5b7177439d3c7c554d85052f0ec9acdfe1ea3b60083959406cf032466bedfd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
