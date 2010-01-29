# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_airbag_session',
  :secret      => '78aaee88e4e1b3548050b677718f212a2a55dbf188214df636e57ac42e732e78e94834552bf2c2bf26cc782f3d7926897643ef1e74fd469aaf898503d2e22b47'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
