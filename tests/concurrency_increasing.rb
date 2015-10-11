require 'ruby-jmeter'

test do
  defaults domain: 'loadtest.flood.io',
           protocol: 'https'

  with_user_agent :chrome

  with_gzip

  stepping_thread_group   total_threads: 2000,
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
  name: 'Increasing Concurrency on Shopping Cart'
}
