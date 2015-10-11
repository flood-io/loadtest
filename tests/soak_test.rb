require 'ruby-jmeter'

test do
  defaults domain: 'loadtest.flood.io',
           protocol: 'https'

  with_user_agent :chrome

  with_gzip

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

    get name: 'Home', url: '/' do
      extract name: 'token', css: 'input#authenticity_token'
    end

    post name: 'Sign in', url: '/app/submit/login', fill_in: {
      username: 'loadtester',
      password: 'mrRobot',
      token: '${token}'
    }

    post name: 'Search for item', url: '/app/search', fill_in: {
      product: 'Blank CD'
    }

    get name: 'Search for random item', url: '/app/search/technology' do
      extract name: 'first_item_id', regex: '.class="item" id="(.+?)'
    end

    get name: 'View cart', url: '/app/view/cart'

    post name: 'Add item to cart', url: '/app/submit/item',
      raw_body: {
        name: "Blank CD",
        price: 10,
        quantity: 24,
        product_id: "${first_item_id"
      }.to_json

    put name: 'Remove item from cart', url: '/app/remove/item'

    get name: 'Checkout', url: '/app/checkout'

    get name: 'Confirm payment details', url: '/app/checkout/payment'

    get name: 'Contact support', url: '/app/support'
  end
end.flood ENV['FLOOD_API_TOKEN'], {
  region: 'us-west-2',
  privacy: 'public',
  name: 'Shopping Cart Soak Test'
}
# end.run(path: '/usr/share/jmeter-2.13/bin/', gui: true)
# end.jmx