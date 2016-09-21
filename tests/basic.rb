require 'ruby-jmeter'

test do
  defaults  domain: 'flooded.io', port: 80

  threads count: 10, loops: 5 do

    get url: '/api'

  end
end.flood ENV['FLOOD_API_TOKEN'], privacy_flag: 'public',

