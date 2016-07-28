require 'ruby-jmeter'

test do
  defaults domain: 'loadtest.flood.io',
           protocol: 'https',
           image_parser: false

  with_user_agent :chrome

  header [
    { name: 'Accept-Encoding', value: 'gzip,deflate,sdch' },
    { name: 'Accept', value: 'text/javascript, text/html, application/xml, text/xml, */*' }
  ]

  threads count: 100, duration: 600 do # threads = RPS * <max response time ms> / 1000

    throughput_shaper 'increasing load test', [
      { :start_rps => 100, :end_rps => 100, :duration => 60 },
      { :start_rps => 200, :end_rps => 200, :duration => 60 },
      { :start_rps => 300, :end_rps => 300, :duration => 60 },
      { :start_rps => 400, :end_rps => 400, :duration => 60 },
      { :start_rps => 500, :end_rps => 500, :duration => 60 },
      { :start_rps => 600, :end_rps => 600, :duration => 60 },
      { :start_rps => 700, :end_rps => 700, :duration => 60 },
      { :start_rps => 800, :end_rps => 800, :duration => 60 },
      { :start_rps => 900, :end_rps => 900, :duration => 60 },
      { :start_rps => 1000, :end_rps => 1000, :duration => 60 }
    ]

    get name: '/home',     url: '/'

    # view_results
  end
end.flood ENV['FLOOD_API_TOKEN'], {
  privacy: 'public',
  name: 'Increasing RPM',
  tags: 'shakeout',
  override_parameters: '-Dsun.net.inetaddr.ttl=0'
}
# end.run(path: '/usr/share/jmeter-2.13/bin/', gui: true)
# end.jmx
