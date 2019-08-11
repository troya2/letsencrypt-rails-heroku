require 'letsencrypt-rails-heroku/letsencrypt'
require 'letsencrypt-rails-heroku/middleware'
require 'letsencrypt-rails-heroku/exceptions'
require 'letsencrypt-rails-heroku/verifiers'
require 'letsencrypt-rails-heroku/dnsimple'

if defined?(Rails)
  require 'letsencrypt-rails-heroku/railtie'
end
