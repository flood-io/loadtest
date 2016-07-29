require 'ruby-jmeter'

test do
  # defaults  domain: '7wam4h0629.execute-api.us-west-2.amazonaws.com',
  defaults  domain: 'flooded.io',
            port: 443,
            protocol: 'https',
            implementation: 'HttpClient3.1'

  with_user_agent :iphone

  header [
    { name: 'x-api-key', value: 'BguwPvwIHD4vTTq2MHL3HTWKibe4LHC9GZYV4FUi' },
    { name: 'Authorization', value: 'Basic ZGVtb3VzZXI6ZGVtb3VzZXI=' },
    { name: 'Accept', value: 'application/json' },
  ]

  step  total_threads: '${__P(threads, 1000)}',
        initial_delay: 0,
        start_threads: 20,
        add_threads: 0,
        start_every: 30,
        stop_threads: 50,
        stop_every: 5,
        flight_time: 1_800,
        rampup: 5 do

    random_timer 500, 1_000

    get name: 'entry point', url: '/api' do
      assert json: '.status', value: 'OK'
    end

    post name: 'create session', url: '/api/oauth',
      fill_in: {
        username: 'Michel Rosen',
        password: 4141414141
      } do
        extract json: '.access_token', name: 'access_token'
      with_xhr
    end

    get name: 'search', url: '/api/search',
      raw_body: '{"name":"Gumboots","price":10,"vendor_attendance_id":24,"product_id":1}' do
      assert json: '.status', value: 'OK'
    end

    get name: 'get shipping estimate', url: '/api/shipping',
      raw_body: '{"postcode":"3781","state":"VIC","weight":850,"unit":"grams"}' do
      assert json: '.status', value: 'OK'
    end

    post name: 'add to cart', url: '/api/cart',
      raw_body: '{"id":"1000101","quantity":10}' do
      assert json: '.status', value: 'OK'
    end

    delete name: 'remove from cart', url: '/api/cart',
      raw_body: '{"id":"1000101","quantity":10}' do
      assert json: '.status', value: 'OK'
    end

    get name: 'view cart', url: '/api/cart' do
      assert json: '.status', value: 'OK'
    end

    delete name: 'destroy session', url: '/api/oauth?connections=${access_token_1}' do
      duration_assertion duration: 5_000
    end

    # view_results
  end
# end.jmx
end.run(path: '/usr/share/jmeter-3.0/bin/', gui: true)
# end.flood ENV['FLOOD_API_TOKEN'], {
#   privacy: 'public',
#   name: 'Shakeout Loadtest API',
#   override_parameters: '-Dsun.net.inetaddr.ttl=0'
# }