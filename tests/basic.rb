require 'ruby-jmeter'

test do
  defaults  domain: 'localhost', port: 8008

  threads count: 1, loops: 1 do

    get url: '/api'

  end
end.run(path: '/usr/share/jmeter/bin/')
