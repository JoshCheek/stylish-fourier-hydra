require 'graphics'
require_relative 'fourier'

class ShowFourier < Graphics::Simulation
  def initialize(points, width, height, num_colours)
    super width, height, num_colours
    @frequencies = Fourier.to(points)
    @m = @frequencies.length
    @mode = :points
    add_keydown_handler("j") { self.m = m - 1 }
    add_keydown_handler("k") { self.m = m + 1 }
    add_keydown_handler("p") { @mode = :points }
    add_keydown_handler("f") { @mode = :frequencies }
  end

  def draw(iteration)
    n = @frequencies.length
    clear :black
    text "#{m}/#{n}", 50, h-50, :white
    frequencies = @frequencies.take(m)
    case mode
    when :points
      points = Fourier.from frequencies
    when :frequencies
      points = frequencies
    else raise "Wat? #{mode.inspect}"
    end
    points.each_cons(2) { |p1, p2| line *p1, *p2, :white }
  end

  private

  attr_reader :m, :mode

  def m=(m)
    m  = 2 if m < 2
    m  = @frequencies.length if @frequencies.length < m
    @m = m
  end
end

w = 800
h = 600
r = 250
n = 8

# circle
circle = n.times.map do |i|
  [r*Math.cos(i*2*Math::PI/n)+w/2, r*Math.sin(i*2*Math::PI/n)+h/2]
end

# square
square =
  (n/4).times.map { |i| [ w/2+r           , h/2+r - r*8*i/n ] } +
  (n/4).times.map { |i| [ w/2+r - r*8*i/n , h/2-r           ] } +
  (n/4).times.map { |i| [ w/2-r           , h/2-r + r*8*i/n ] } +
  (n/4).times.map { |i| [ w/2-r + r*8*i/n , h/2+r           ] }

# note: https://www.mobilefish.com/services/record_mouse_coordinates/record_mouse_coordinates.php
note = %w[193,47 140,204 123,193 99,189 74,196 58,213 49,237 52,261 65,279 86,292 113,295 135,282 152,258 201,95 212,127 218,150 213,168 201,185 192,200 203,214 219,205 233,191 242,170 244,149 242,131 233,111]
           .map { |n|
             x, y = n.split(?,).map(&:to_i)
             [x*2, h-y]
           }


# Normalize the points
points = note
points = points.dup
points.push points[0]
xmin, xmax = points.map(&:first).minmax
ymin, ymax = points.map(&:last).minmax
points = points.map do |x, y|
  [x - xmin + 10, y - ymin + 10]
end

# Draw it
ShowFourier.new(points, w, h, 31).run
