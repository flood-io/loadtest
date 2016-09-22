require 'ruby-jmeter'

test do
  defaults  domain: 'localhost', port: 8008, protocol: 'http',
            proxy_host: 'localhost', proxy_port: 8080

  threads count: 10, loops: 5, rampup: 30 do
    random_timer 1000, 2000

    get url: '/api'

    post name: 'create session', url: "/api/oauth",
      fill_in: {
        username: 'Michel Rosen',
        password: 4141414141
      } do
        extract json: '.access_token', name: 'access_token'
      with_xhr
    end

  end
end.run(path: '/usr/share/jmeter/bin/')
