require 'ruby-jmeter'

test do
  defaults  domain: 'flooded.io', port: 443, protocol: 'https'

  threads count: 10, loops: 5, rampup: 30 do
    random_timer 1000, 2000

    get url: '/api'

  end
end.flood ENV['FLOOD_API_TOKEN'], privacy: 'public'
