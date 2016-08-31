require 'ruby-jmeter'

test do
  defaults  domain: ENV['DOMAIN'] ||= 'flooded.io',
            port: ENV['PORT'] ||= 443,
            protocol: ENV['PROTOCOL'] ||= 'https',
            implementation: 'HttpClient4'

  with_user_agent :iphone

  header [
    { name: 'Accept', value: 'application/json' }
  ]

  step  total_threads: ENV['THREADS'].to_i ||= 500,
        initial_delay: 0,
        start_threads: 20,
        add_threads: 0,
        start_every: 30,
        stop_threads: 50,
        stop_every: 5,
        flight_time: 1_800,
        rampup: 5 do

    random_timer 100, 200

    get name: 'entry point', url: '/api', sample: 10 do
      assert json: '.status', value: 'OK'
    end

    post name: 'create session', url: '/api/oauth', sample: 10,
      fill_in: {
        username: 'Michel Rosen',
        password: 4141414141
      } do
        extract json: '.access_token', name: 'access_token'
      with_xhr
    end

    get name: 'search', url: '/api/search', sample: 10,
      raw_body: '{"name":"Gumboots","price":10,"vendor_attendance_id":24,"product_id":1}' do
      assert json: '.status', value: 'OK'
    end

    get name: 'get shipping estimate', url: '/api/shipping', sample: 10,
      raw_body: '{"postcode":"3781","state":"VIC","weight":850,"unit":"grams"}' do
      assert json: '.status', value: 'OK'
    end

    post name: 'add to cart', url: '/api/cart', sample: 10,
      raw_body: '{"id":"1000101","quantity":10}' do
      assert json: '.status', value: 'OK'
    end

    delete name: 'remove from cart', url: '/api/cart', sample: 10,
      raw_body: '{"id":"1000101","quantity":10}' do
      assert json: '.status', value: 'OK'
    end

    get name: 'view cart', url: '/api/cart', sample: 10 do
      assert json: '.status', value: 'OK'
    end

    delete name: 'destroy session', url: '/api/oauth?connections=${access_token_1}', sample: 10 do
      duration_assertion duration: 5_000
    end

    # view_results
  end
# end.run(path: '/usr/share/jmeter-3.0/bin/', gui: true)
end.flood ENV['FLOOD_API_TOKEN'],
  privacy: 'public',
  name: ENV['FLOOD_NAME'] ||= 'Loadtest API',
  project: 'API Testing',
  region: ENV['REGION'] ||= 'us-west-2',
  override_parameters: '-Dsun.net.inetaddr.ttl=30'
