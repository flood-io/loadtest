require 'awesome_print'
require 'ascii_charts'
require 'poisson'
require 'descriptive_statistics'

@threads_range = 1000..5000
@session_duration_range = 0..10
@threads_uniques = 180_000
distribution = ARGV[0] || :average

def average(minute)
  [Array(@threads_range).median.to_i, minute + Array(@session_duration_range).median]
end

def random_duration(minute)
  [Array(@threads_range).median.to_i, minute + rand(@session_duration_range)]
end

def poisson(minute)
  λ = 20
  probability = Poisson.new(λ).probability { |x| x == minute }

  [(probability * @threads_uniques).to_i, minute + rand(@session_duration_range)]
end

def chart(distribution = :average)
  @_chart = []
  active_threads = {}

  60.times do |minute|
    minute += 1
    concurrency = 0
    active_threads[minute] = send(distribution, minute)
    active_threads.each { |_id, t| concurrency += t.first if t.last > minute }
    @_chart << [minute, concurrency]
  end

  @_chart.delete_if {|i| !0.step(60, 2).to_a.include?(i.first) }
end

puts AsciiCharts::Cartesian.new(chart(distribution.to_sym), bar: true, hide_zero: true).draw
