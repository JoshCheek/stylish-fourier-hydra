require 'graphics'
require_relative 'fourier'

class DrawFourier < Graphics::Simulation
  def initialize(*)
    super
    @points = []
    @state  = [:get_points]
  end

  def draw(iteration)
    clear :black
    if @state[0] == :get_points
      text "Draw with the mouse, click when done", 50, 50, :white
      x, y, clicked, * = mouse
      if clicked
        @frequencies = Fourier.to(@points)
        @state = [:transform, iteration]
      else
        point = [x, y]
        @points << point unless point == @points.last
      end
      draw_points @points
    else
      n = @frequencies.length
      m = n - (iteration - @state[1]) + 1
      text "#{m}/#{n}", 50, 50, :white
      draw_points Fourier.from(@frequencies, m)
      sleep 1 unless m == n
    end
  end

  private def draw_points(points)
    points.each_cons(2) { |p1, p2| line *p1, *p2, :white }
  end
end

DrawFourier.new(800, 600, 31).run
