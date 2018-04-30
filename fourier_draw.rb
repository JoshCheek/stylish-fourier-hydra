require 'graphics'
require_relative 'fourier'

class ShowFourier < Graphics::Simulation
  include Math

  def initialize(points, width, height, num_colours)
    super width, height, num_colours
    @frequencies = Fourier.to(points)
    @progress = []
    @x_off = w/2
    @y_off = h/2
  end

  def draw(iteration)
    clear :black
    n = @frequencies.length
    iteration = 1 + (iteration / 10)

    # the machine to draw it all
    two_pi = 2*PI
    p_no_u = two_pi*iteration.pred/n
    mag_and_angle = @frequencies.each_with_index.map do |(f_real, f_imag), u|
      [f_real, f_imag, p_no_u*u]
    end

    sum_x = sum_y = 0

    pts = []
    mag_and_angle.each do |r, i, ø|
      c, s = cos(ø), sin(ø)
      sum_x += c*r + s*i
      sum_y += c*i - s*r
      mag = sqrt(r*r + i*i)

      # omit spammy results
      if 2 <= mag
        center_circle sum_x, sum_y, mag, :white unless mag < 2
        pts << sum_x << sum_y
      end
    end

    last_x, last_y = pts.last(2)
    draw_points pts, :green#, true

    # crosshairs
    center_line last_x, -h, last_x, 2*h, :red# , true
    center_line -w, last_y, 2*w, last_y, :red# , true

    # the drawing up to this point
    p_no_u = two_pi*iteration.pred/n
    real = imaginary = 0
    @frequencies.each_with_index do |(f_real, f_imaginary), u|
      p = p_no_u*u
      c, s = cos(p), sin(p)
      real      += c*f_real      + s*f_imaginary
      imaginary += c*f_imaginary - s*f_real
    end
    @progress << real << imaginary

    draw_points @progress, :magenta, true
  end

  def draw_points(points, colour, thick = false)
    0.step by: 2, to: points.length-3 do |i|
      center_line points[i+0], points[i+1], points[i+2], points[i+3], colour, thick
    end
  end

  def center_circle(x, y, r, colour)
    circle x+w/2, y+h/2, r, colour
  end

  def center_line(x1, y1, x2, y2, colour, thick=false)
    x1 += @x_off
    x2 += @x_off
    y1 += @y_off
    y2 += @y_off
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

xmin, xmax = points.map(&:first).minmax
ymin, ymax = points.map(&:last).minmax
points = points.map do |x, y|
  [ (xmax - xmin) / 2 + x - xmin - w/2,
    (ymax - ymin) / 2 + y - ymin - h/2,
  ]
end

points = [[540, 440], [538, 463], [532, 485], [523, 507], [510, 526], [495, 543], [477, 557], [456, 568], [434, 576], [412, 580], [388, 580], [366, 576], [344, 568], [323, 557], [305, 543], [290, 526], [277, 507], [268, 485], [262, 463], [260, 440], [260, 440], [237, 438], [215, 432], [193, 423], [174, 410], [157, 395], [143, 377], [132, 356], [124, 334], [120, 312], [120, 288], [124, 266], [132, 244], [143, 223], [157, 205], [174, 190], [193, 177], [215, 168], [237, 162], [260, 160], [260, 160], [262, 137], [268, 115], [277, 93], [290, 74], [305, 57], [323, 43], [344, 32], [366, 24], [388, 20], [412, 20], [434, 24], [456, 32], [477, 43], [495, 57], [510, 74], [523, 93], [532, 115], [538, 137], [540, 160], [540, 160], [563, 162], [585, 168], [607, 177], [626, 190], [643, 205], [657, 223], [668, 244], [676, 266], [680, 288], [680, 312], [676, 334], [668, 356], [657, 377], [643, 395], [626, 410], [607, 423], [585, 432], [563, 438], [540, 440]]
          .map { |x, y| [x-w/2, y-h/2] }

points.push points[0]

# Draw it
ShowFourier.new(points, w, h, 31).run
