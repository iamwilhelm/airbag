require 'yaml'

# loads the email settings from config/email.yml
settings = YAML.load_file(File.join(RAILS_ROOT, "config", "email.yml"))
unless settings[RAILS_ENV].nil? or settings[RAILS_ENV].empty?
  ActionMailer::Base.delivery_method = settings[RAILS_ENV].delete("delivery_method")
  ActionMailer::Base.smtp_settings = settings[RAILS_ENV]
else
  ActionMailer::Base.delivery_method = :test
end
