require 'ruby-jmeter'

test do
  defaults  domain: '7wam4h0629.execute-api.us-west-2.amazonaws.com',
            port: 443,
            protocol: 'https',
            implementation: 'HttpClient3.1' # https://bz.apache.org/bugzilla/show_bug.cgi?id=57935

  with_user_agent :iphone

  header [
    { name: 'x-api-key', value: 'BguwPvwIHD4vTTq2MHL3HTWKibe4LHC9GZYV4FUi' },
    { name: 'Accept', value: 'application/json' },
  ]

  step  total_threads: 1_000,
        initial_delay: 0,
        start_threads: 20,
        add_threads: 0,
        start_every: 30,
        stop_threads: 50,
        stop_every: 5,
        flight_time: 1_800,
        rampup: 5 do

    random_timer 500, 1_000

    get name: 'entry point', url: '/production' do
      assert json: '.status', value: 'OK'
    end

    post name: 'create session', url: '/production',
      fill_in: {
        username: 'MrRobot',
        password: 4141414141
      } do
        extract json: '.connections_active', name: 'connections_active'
      with_xhr
    end

    delete name: 'destroy session', url: '/production?connections=${connections_active_1}' do
      duration_assertion duration: 5_000
    end

    view_results
  end
end.flood ENV['FLOOD_API_TOKEN'], {
  privacy: 'public',
  name: 'Shakeout Loadtest API',
  grid: 'Wvf78fVsSWvTekNftt3ZsQ'
}
# end.run(path: '/usr/share/jmeter-2.13/bin/', gui: true)
