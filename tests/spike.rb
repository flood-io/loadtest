require 'ruby-jmeter'

test do
  defaults  domain: ENV['DOMAIN'] ||= 'flooded.io',
            port: ENV['PORT'] ||= '443',
            protocol: ENV['PROTOCOL'] ||= 'https',
            implementation: 'HttpClient4'

  with_user_agent :iphone
  with_json

  ultimate [
    { start_threads: 200, initial_delay: 0, start_time: 180, hold_time: 900, stop_time: 0 },
    { start_threads: 200, initial_delay: 300, start_time: 60, hold_time: 360, stop_time: 0 },
    { start_threads: 600, initial_delay: 600, start_time: 120, hold_time: 120, stop_time: 0 },
  ], {on_sample_error: 'startnextloop'} do

    random_timer 10, 200

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

    get name: 'search', url: "/#{ENV['VERSION']}/search", sample: 10,
      raw_body: '{"name":"Gumboots","price":10,"vendor_attendance_id":24,"product_id":1}' do
      assert json: '.status', value: 'OK'
    end

    get name: 'get shipping estimate', url: "/#{ENV['VERSION']}/shipping", sample: 10,
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
  name: ENV['FLOOD_NAME'] ||= 'Spike API',
  project: "API #{ENV['VERSION']}",
  region: ENV['REGION'] ||= 'us-west-2',
  override_parameters: '-Dsun.net.inetaddr.ttl=30'
