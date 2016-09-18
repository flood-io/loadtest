require 'ruby-jmeter'

test do
  defaults  domain: 'localhost',
            port: 8008,
            proxy_host: 'localhost',
            proxy_port: 8080

  threads count: 1, loops: 1 do
    random_timer 100, 200

    with_user_agent :iphone
    with_json

    get name: 'entry point', url: '/api' do
      assert json: '.status', value: 'OK'
    end

    post name: 'oauth', url: '/api/oauth',
      fill_in: {
        username: 'Michel Rosen',
        password: 4141414141
      }
  end
end.run(path: '/usr/share/jmeter/bin/')
