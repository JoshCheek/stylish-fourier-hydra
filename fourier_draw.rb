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
    iteration = 1 + (iteration / 20)

    clear :black
    n = @frequencies.length

    mag_and_angle = @frequencies.each_with_index.flat_map { |(f_real, f_imaginary), u|
      p = 2*PI * u * iteration.pred/n
      [ [f_real,       p],
        [-f_imaginary, p + PI/2],
      ]
    }

    sum_x = sum_y = 0

    pts = mag_and_angle.map.with_index do |(mag, angle), i|
      sum_x += mag*cos(angle)
      sum_y -= mag*sin(angle)
      center_circle sum_x, sum_y, mag, :white if 1 < i
      [sum_x, sum_y]
    end
    last_x, last_y = pts.last
    # center_circle *pts[-1], mag_and_angle[-1][0].abs, :yellow

    center_line last_x, -h, last_x, 2*h, :red, true
    center_line -w, last_y, 2*w, last_y, :red, true
    draw_points pts.drop(1), :green, true

    # # increased sample rate
    # draw_points \
    #   2000.times.map { |k|
    #     real = imaginary = 0
    #     @frequencies.each_with_index do |(f_real, f_imaginary), u|
    #       p = 2*PI*u*k/2000*iteration.pred/n
    #       c, s = cos(p), sin(p)
    #       real      += c*f_real      + s*f_imaginary
    #       imaginary += c*f_imaginary - s*f_real
    #     end
    #     [real, imaginary]
    #   },
    #   :red

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
points = %w[193,47 140,204 123,193 99,189 74,196 58,213 49,237 52,261 65,279 86,292 113,295 135,282 152,258 201,95 212,127 218,150 213,168 201,185 192,200 203,214 219,205 233,191 242,170 244,149 242,131 233,111]
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
