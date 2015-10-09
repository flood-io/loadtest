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

  step  total_threads: 2000,
          initial_delay: 0,
          start_threads: 200,
          add_threads: 0,
          start_every: 60,
          stop_threads: 50,
          stop_every: 5,
          flight_time: 60,
          rampup: 5 do

    get name: '/slow',     url: '/slow'

    # view_results
  end
end.flood ENV['FLOOD_API_TOKEN'], {
  region: 'us-west-2',
  privacy: 'public',
  name: 'Increasing Concurrency',
  tags: 'shakeout'
}
# end.run(path: '/usr/share/jmeter-2.13/bin/', gui: true)
# end.jmx
