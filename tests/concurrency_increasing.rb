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

    get name: 'Home', url: '/' do
      extract name: 'token', css: 'input#authenticity_token'
    end

    post name: 'Sign in', url: '/app/submit/login', fill_in: {
      username: 'loadtester',
      password: 'mrRobot',
      token: '${token}'
    }

    post name: 'Search for item', url: '/app/search', fill_in: {
      product: 'USB stick'
    }

    get name: 'Search for random item', url: '/app/search/technology'




    get name: 'View cart',              url: '/slow'
    get name: 'Add item to cart',            url: '/random'
    get name: 'Remove item from cart',       url: '/random'
    get name: 'Checkout',     url: '/slow'
    get name: 'Confirm payment details',     url: '/degrading'
    get name: 'Contact support',     url: '/'

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
