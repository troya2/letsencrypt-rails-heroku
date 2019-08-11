class LetsencryptRailsHerokuRailtie < Rails::Railtie
  config.before_configuration do
    Letsencrypt.configure
    Letsencrypt::Dnsimple.configure
  end

  rake_tasks do
    load 'tasks/letsencrypt.rake'
  end
end
