require 'graphics'
require_relative 'fourier'

class ShowFourier < Graphics::Simulation
  include Math

  def initialize(points, width, height, num_colours)
    super width, height, num_colours
    @real_y_off = (points.map(&:last).max + height) / 2.0
    @real_x_off = points.map(&:first).minmax.tap { |min, max| break (min + max) / 2.0 }
    @frequencies = Fourier.to(points)
    @progress = 0
  end

  def draw(iteration)
    iteration = 1 + (iteration / 4)
    clear :black
    n = @frequencies.length

    draw_points \
      2000.times.map { |k|
        real = imaginary = 0
        @frequencies.each_with_index do |(f_real, f_imaginary), u|
          p = 2*PI*u*k/2000*iteration.pred/n
          c, s = cos(p), sin(p)
          real      += c*f_real      + s*f_imaginary
          imaginary += c*f_imaginary - s*f_real
        end
        [real, imaginary]
      },
      :red

    draw_points \
      iteration.times.map { |k|
        real = imaginary = 0
        @frequencies.each_with_index do |(f_real, f_imaginary), u|
          p = 2*PI*u*k/n
          c, s = cos(p), sin(p)
          real      += c*f_real      + s*f_imaginary
          imaginary += c*f_imaginary - s*f_real
        end
        [real, imaginary]
      },
      :white,
      true

    # @real_x_off = 0
    # @real_y_off = 0
    # real_x = 0
    # real_y = 0
    # @frequencies.each_with_index do |(f_real, f_imaginary), u|
    #   p = 2*PI*u*iteration/n
    #   r = Math.sqrt(cos(p)**2 + sin(p)**2)
    #   next_real_x = real_x + cos(p)*f_real + sin(p)*f_imaginary
    #   next_real_y = u * 10
    #   line @real_x_off + real_x,      @real_y_off + real_y,
    #        @real_x_off + next_real_x, @real_y_off + next_real_y,
    #        :red
    #   real_x = next_real_x
    #   real_y = next_real_y
    # end
  end

  def draw_points(points, colour, thick = false)
    points.each_cons(2) do |p1, p2|
      line *p1, *p2, colour, thick
    end
  end

  def line(x1, y1, x2, y2, colour, thick)
    super x1, y1, x2, y2, colour
    if thick
      super x1+1, y1, x2+1, y2, colour
      super x1-1, y1, x2-1, y2, colour
      super x1, y1+1, x2, y2+1, colour
      super x1, y1-1, x2, y2-1, colour
    end
  end
end

w, h = 800, 600

# note: https://www.mobilefish.com/services/record_mouse_coordinates/record_mouse_coordinates.php
points = %w[193,47 140,204 123,193 99,189 74,196 58,213 49,237 52,261 65,279 86,292 113,295 135,282 152,258 201,95 212,127 218,150 213,168 201,185 192,200 203,214 219,205 233,191 242,170 244,149 242,131 233,111]
           .map { |n|
             x, y = n.split(?,).map(&:to_i)
             [x*2, h-y]
           }
points.push points[0]

xmin, xmax = points.map(&:first).minmax
ymin, ymax = points.map(&:last).minmax
points = points.map do |x, y|
  [ (xmax - xmin) / 2 + x - xmin,
    (ymax - ymin) / 2 + y - ymin,
  ]
  # [x - xmin + 10, y - ymin + 10]
end

# Draw it
ShowFourier.new(points, w, h, 31).run
