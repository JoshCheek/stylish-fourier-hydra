require 'graphics'
require_relative 'fourier'

class ShowFourier < Graphics::Simulation
  include Math

  def initialize(points, width, height)
    super width, height

    @frequencies = Fourier.to(points)
    @progress = []
    @x_off = w/2
    @y_off = h/2
  end

  def draw(iteration)
    clear :black
    n = @frequencies.length

    # you can divide here to slow it down, but it loses its smoothness.
    # It's better to add more samples instead.
    iteration = 1 + (iteration)

    # the machine to draw it all
    two_pi = 2*PI
    p_no_u = two_pi*iteration.pred/n
    mag_and_angle = @frequencies.each_with_index.map do |(f_real, f_imag), u|
      [f_real, f_imag, p_no_u*u]
    end

    mag_and_angle.sort_by! do |f_real, f_imag|
      -Math.sqrt(f_real**2 + f_imag**2)
    end

    sum_x = sum_y = 0

    pts = [0,0]
    mags = []
    mag_and_angle.each do |r, i, ø|
      c, s = cos(ø), sin(ø)
      sum_x += c*r + s*i
      sum_y += c*i - s*r
      mag = sqrt(r*r + i*i)

      # omit spammy results
      if 1 <= mag
        mags << mag
        pts << sum_x << sum_y
      end
    end

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

    # translate?
    if $centered
      @screen_x_mid ||= real
      @screen_y_mid ||= imaginary
      @screen_x_mid += (real - @screen_x_mid)/10
      @screen_y_mid += (imaginary - @screen_y_mid)/10

      pts = pts.each_slice(2).flat_map { |x, y| [x-@screen_x_mid, y-@screen_y_mid] }
      progress = @progress.each_slice(2).flat_map { |x, y| [x-@screen_x_mid, y-@screen_y_mid] }
    else
      progress = @progress
    end

    # draw things
    pts.each_slice(2).zip mags do |(x, y), mag|
      center_circle x, y, mag, :gray100 if mag
    end

    last_x, last_y = pts.last(2)
    draw_points pts, :green#, true

    # crosshairs
    if $crosshairs
      center_line last_x, -h, last_x, 2*h, :red# , true
      center_line -w, last_y, 2*w, last_y, :red# , true
    end

    draw_points progress, :magenta, true
  end

  def draw_points(points, colour, thick = false)
    0.step by: 2, to: points.length-3 do |i|
      x1 = points[i+0]
      y1 = points[i+1]
      x2 = points[i+2]
      y2 = points[i+3]
      center_line x1, y1, x2, y2, colour, thick
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
      line x1+2, y1, x2+2, y2, colour
      line x1+1, y1, x2+1, y2, colour
      line x1-1, y1, x2-1, y2, colour
      line x1-2, y1, x2-2, y2, colour
      line x1, y1+2, x2, y2+2, colour
      line x1, y1+1, x2, y2+1, colour
      line x1, y1-1, x2, y2-1, colour
      line x1, y1-2, x2, y2-2, colour
    end
  end
end

w, h = 800, 600
w, h = 1200, 850
margin = 30

require "json"
points = JSON.parse File.read "points.json"
# p points

xmin, xmax = points.map(&:first).minmax
ymin, ymax = points.map(&:last).minmax
∆x = (xmax - xmin)
∆y = (ymax - ymin)
∆  = [∆x, ∆y].max
points.map! do |x, y|
  x = (x-xmin)/∆ - 0.5
  y = (y-ymin)/∆ - 0.5
  [-x, -y].map { |n| n * 0.9 } # add a margin
end

xmin, xmax = points.map(&:first).minmax
ymin, ymax = points.map(&:last).minmax
∆x = (xmax - xmin)
∆y = (ymax - ymin)
screen_ratio = w.to_f / h
image_ratio  = ∆x.to_f / ∆y

if screen_ratio > image_ratio
  # y axis is the constraining dimension
  divide   = ∆y
  multiply = h - 2*margin
  xoff     = (w-∆x/divide*multiply)/2
  yoff     = 0
else
  # x axis is the constraining dimension
  divide   = ∆x
  multiply = w - 2*margin
  xoff     = 0
  yoff     = (h-∆y/divide*multiply)/2
end

# normalize
points = points.map do |x, y|
  # resize SVG to fit on screen
  x -= xmin
  y -= ymin
  x /= divide
  y /= divide
  x *= multiply
  y *= multiply
  x += margin
  y += margin

  # potentially zoom
  if $zoom =~ /\A\d+/
    zoom = $zoom.to_i
  elsif $zoom
    zoom = 5
  end

  if zoom
    x *= zoom
    y *= zoom
    y -= 100
  end

  # center it
  x -= w/2
  y -= h/2
  x += xoff
  y += yoff

  [x, y]
end


xmin, xmax = points.map(&:first).minmax
ymin, ymax = points.map(&:last).minmax

# Draw it
# ShowNormal.new(points, w, h).run
ShowFourier.new(points, w, h).run
