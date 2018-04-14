require 'graphics'
require_relative 'fourier'

class ShowFourier < Graphics::Simulation
  def initialize(points, width, height, num_colours)
    super width, height, num_colours
    @frequencies = Fourier.to(points)
  end

  def draw(iteration)
    clear :black
    n = @frequencies.length
    m = n - iteration + 1
    return if m < 2
    text "#{m}/#{n}", 50, 50, :white
    points = Fourier.from(@frequencies, m)
    points.each_cons(2) { |p1, p2| line *p1, *p2, :white }
    sleep 0.1
  end
end

w = 800
h = 600
r = 250
n = 100

# circle
points = n.times.map do |i|
  [r*Math.cos(i*2*Math::PI/n)+w/2, r*Math.sin(i*2*Math::PI/n)+h/2]
end

# square
points =
  (n/4).times.map { |i| [ w/2+r           , h/2+r - r*8*i/n ] } +
  (n/4).times.map { |i| [ w/2+r - r*8*i/n , h/2-r           ] } +
  (n/4).times.map { |i| [ w/2-r           , h/2-r + r*8*i/n ] } +
  (n/4).times.map { |i| [ w/2-r + r*8*i/n , h/2+r           ] }

points.push points[0]
ShowFourier.new(points, w, h, 31).run
