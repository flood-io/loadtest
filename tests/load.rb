require 'ruby-jmeter'

test do
  defaults  domain: ENV['DOMAIN'] ||= 'flooded.io',
            port: ENV['PORT'] ||= '443',
            protocol: ENV['PROTOCOL'] ||= 'https',
            implementation: 'HttpClient4'

  with_user_agent :iphone
  with_json

  step  total_threads: ENV.fetch('THREADS', 500),
        initial_delay: 0,
        start_threads: 100,
        add_threads: 0,
        start_every: 60,
        stop_threads: ENV.fetch('THREADS', 500),
        stop_every: 5,
        flight_time: 600,
        rampup: 60 do

    random_timer 100, 200

    get name: 'entry point', url: "/#{ENV['VERSION']}", sample: 10 do
      assert json: '.status', value: 'OK'
    end

    post name: 'create session', url: "/#{ENV['VERSION']}/oauth", sample: 10,
      fill_in: {
        username: 'Michel Rosen',
        password: 4141414141
      } do
        extract json: '.access_token', name: 'access_token'
      with_xhr
    end

    post name: 'search', url: "/#{ENV['VERSION']}/search", sample: 10,
      raw_body: '{"name":"Gumboots","price":10,"vendor_attendance_id":24,"product_id":1}' do
      assert json: '.status', value: 'OK'
    end

    post name: 'get shipping estimate', url: "/#{ENV['VERSION']}/shipping", sample: 10,
      raw_body: '{"postcode":"3781","state":"VIC","weight":850,"unit":"grams"}' do
      assert json: '.status', value: 'OK'
    end

    post name: 'add to cart', url: "/#{ENV['VERSION']}/cart", sample: 10,
      raw_body: '{"id":"1000101","quantity":10}' do
      assert json: '.status', value: 'OK'
    end

    delete name: 'remove from cart', url: "/#{ENV['VERSION']}/cart", sample: 10,
      raw_body: '{"id":"1000101","quantity":10}' do
      assert json: '.status', value: 'OK'
    end

    get name: 'view cart', url: "/#{ENV['VERSION']}/cart", sample: 10 do
      assert json: '.status', value: 'OK'
    end

    delete name: 'destroy session', url: "/#{ENV['VERSION']}/oauth?connections=${access_token_1}", sample: 10 do
      duration_assertion duration: 5_000
    end
  end
end.flood ENV['FLOOD_API_TOKEN'],
  privacy: 'public',
  name: ENV['FLOOD_NAME'] ||= 'Loadtest API',
  project: "API #{ENV['VERSION']}",
  region: ENV['REGION'] ||= 'us-west-2',
  override_parameters: '-Dsun.net.inetaddr.ttl=30'
