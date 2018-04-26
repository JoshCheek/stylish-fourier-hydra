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
    clear :black
    n = @frequencies.length
    iteration = 1 + (iteration / 20)

    mag_and_angle = @frequencies.each_with_index.map do |(f_real, f_imag), u|
      p = 2*PI * u * iteration.pred/n
      [f_real, f_imag, p]
    end

    sum_x = sum_y = 0

    pts = mag_and_angle.map do |r, i, ø|
      c, s = cos(ø), sin(ø)
      sum_x += c*r + s*i
      sum_y += c*i - s*r
      mag = sqrt(r*r + i*i)
      center_circle sum_x, sum_y, mag, :white
      [sum_x, sum_y]
    end

    last_x, last_y = pts.last
    draw_points pts, :green, true

    # crosshairs
    center_line last_x, -h, last_x, 2*h, :red, true
    center_line -w, last_y, 2*w, last_y, :red, true

    # the drawing up to this point
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
      :magenta,
      true
  end

  def draw_points(points, colour, thick = false)
    points.each_cons(2) do |p1, p2|
      center_line *p1, *p2, colour, thick
    end
  end

  def center_circle(x, y, r, colour)
    circle x+w/2, y+h/2, r, colour
  end

  def center_line(x1, y1, x2, y2, colour, thick=false)
    x1 += w/2
    x2 += w/2
    y1 += h/2
    y2 += h/2
    line x1, y1, x2, y2, colour
    if thick
      line x1+1, y1, x2+1, y2, colour
      line x1-1, y1, x2-1, y2, colour
      line x1, y1+1, x2, y2+1, colour
      line x1, y1-1, x2, y2-1, colour
    end
  end
end

w, h = 800, 600

# note: https://www.mobilefish.com/services/record_mouse_coordinates/record_mouse_coordinates.php
points = %w[193,47 166,125 140,204 123,193 99,189 74,196 58,213 49,237 52,261 65,279 86,292 113,295 135,282 152,258 201,95 212,127 218,150 213,168 201,185 192,200 203,214 219,205 233,191 242,170 244,149 242,131 233,111]
           .map { |n|
             x, y = n.split(?,).map(&:to_i)
             [x*2, h-y]
           }
points.push points[0]

xmin, xmax = points.map(&:first).minmax
ymin, ymax = points.map(&:last).minmax
points = points.map do |x, y|
  [ (xmax - xmin) / 2 + x - xmin - w/2,
    (ymax - ymin) / 2 + y - ymin - h/2,
  ]
end

# Draw it
ShowFourier.new(points, w, h, 31).run
