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

  ultimate [
      {
        start_threads: 300,
        initial_delay: 0,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 300,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 600,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 900,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 1200,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 1300,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 1800,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 2100,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 2400,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 2700,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 3000,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 3300,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 3600,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 3900,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 4200,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 4300,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 4600,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 4900,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 5200,
        start_time: 300,
        hold_time: 600,
        stop_time: 5
      },
      {
        start_threads: 300,
        initial_delay: 5500,
        start_time: 300,
        hold_time: 900,
        stop_time: 5
      }
    ] do

    get name: 'Sign in',     url: '/slow'
    get name: 'Home',     url: '/'
    get name: 'View cart',     url: '/slow'
    get name: 'Add item to cart',     url: '/random'
    get name: 'Remove item from cart',     url: '/random'
    get name: 'Search for item',     url: '/degrading'
    get name: 'Search for random items',     url: '/degrading'
    get name: 'Checkout',     url: '/slow'
    get name: 'Confirm payment details',     url: '/degrading'
    get name: 'Contact support',     url: '/'

    # view_results
  end
end.flood ENV['FLOOD_API_TOKEN'], {
  region: 'us-west-2',
  privacy: 'public',
  name: 'NGINX Soak Test',
  tags: 'shakeout'
}
# end.run(path: '/usr/share/jmeter-2.13/bin/', gui: true)
# end.jmx
