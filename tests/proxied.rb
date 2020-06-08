require 'ruby-jmeter'

test do
  defaults  domain: 'localhost',
            port: 8008,
            proxy_host: 'localhost',
            proxy_port: 8080

  with_user_agent :iphone
  with_json

  threads count: 1, loops: 1 do
    random_timer 100, 200

    get name: 'entry point', url: '/api'

  end
end.run(path: '/usr/local/Cellar/jmeter/5.2.1/bin/')
