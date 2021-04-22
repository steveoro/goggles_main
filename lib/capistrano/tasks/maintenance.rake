# frozen_string_literal: true

namespace :maintenance do
  desc 'Sets maintenance mode ON for the dockerized app; applies to both the API and the front-end.'
  task :on do
    on roles(:app) do
      execute(:docker, "exec #{fetch(:app_service)} sh -c 'bundle exec rails maintenance:on'")
    end
  end

  desc 'Sets maintenance mode ON the dockerized app; applies to both the API and the front-end.'
  task :off do
    on roles(:app) do
      execute(:docker, "exec #{fetch(:app_service)} sh -c 'bundle exec rails maintenance:off'")
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Toggles between a static maintenance site & the dockerized running app
  desc <<~DESC
    Toggles between back-ends.

    You can choose between a static maintenance site or the actual running application (in production mode).
    The deploy stage is simply ignored (only production is touched).
    The Apache web server will be restarted at the end.


    ** Parameter: **

    - kind: '[on]' (default) or '[off]'


    ** Usage: **

      > cap <STAGE> maintenance:site[off]
      Sets the application as the actual back-end; this toggles off the static site.
      Note that this is indipendent from the actual maintenance mode setting of the application.

    Or:
      > cap <STAGE> maintenance:site
      > cap <STAGE> maintenance:site[on]
      Both versions sets the static "maintenance" site as back-end; disables the main running application
      without actually stopping its services.

  DESC
  task :site, :kind do |_t, args|
    site_type = args[:kind] || 'on'
    on roles(:app) do
      puts "- Host........: #{host}"
      puts "- Site type...: maintenance #{site_type.upcase}"
      puts ''.rjust(80, '-')
      case site_type
      when 'off'
        info('Toggling Maintenance site OFF...')
        execute(:a2dissite, 'maintenance maintenance-le-ssl')
        execute(:a2ensite, 'goggles-prod goggles-prod-le-ssl')
      else
        info('Toggling Maintenance site ON...')
        execute(:a2dissite, 'goggles-prod goggles-prod-le-ssl')
        execute(:a2ensite, 'maintenance maintenance-le-ssl')
      end
      execute(:systemctl, 'restart apache2')
    end
  end
end
