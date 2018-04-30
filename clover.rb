require 'graphics'

class IDK < Graphics::Simulation
  def initialize(functions, *rest)
    @functions = functions
    super *rest
  end

  def draw(n)
    clear :black
    sample(@functions, n, 20)
      .each_cons(2) { |(x1, y1), (x2, y2)| line x1, y1, x2, y2, :white }
  end
end

def sample(fns, upto, num_fn_samples)
  fns = fns.dup
  points    = []
  while 0 < upto && fns.any?
    fn = fns.shift
    size = [upto, num_fn_samples].min
    upto -= num_fn_samples
    size.times do |crnt|
      points << fn[crnt.to_f/(num_fn_samples-1)]
    end
  end
  points
end

def center(width:, height:, fns:, margin:, maintain_ratio:)
  n_samples   = 100
  samples     = fns.flat_map do |fn|
    n_samples.times.map { |i| fn[i.to_f/(n_samples-1)] }
  end
  xs, ys      = samples.transpose
  minx, maxx  = xs.minmax
  miny, maxy  = ys.minmax
  scale_x     = (width  - 2*margin) / (maxx - minx)
  scale_y     = (height - 2*margin) / (maxy - miny)
  scale_x = scale_y = [scale_x, scale_y].min if maintain_ratio
  translate_x = width  / 2
  translate_y = height / 2
  fns.map do |fn|
    lambda do |t|
      x, y = fn[t]
      # require "pry"
      # binding().pry if 0.5 <= t
      [x * scale_x + translate_x, y * scale_y + translate_y]
    end
  end
end

include Math
width  = 800
height = 600
functions = center(
  width:          width,
  height:         height,
  margin:         20,
  maintain_ratio: true,
  fns:            [
    -> t { [cos(PI*t)            , sin(PI*t)        + 1] }, # top
    -> t { [cos(PI*t+PI/2)   - 1 , sin(PI*t+PI/2)      ] }, # left
    -> t { [cos(PI+PI*t)         , sin(PI+PI*t)     - 1] }, # bottom
    -> t { [cos(PI*t+PI*3/2) + 1 , sin(PI*t+PI*3/2)    ] }, # right
  ],
)

p sample(functions, 20*functions.length, 20).map { |x, y| [x.round, y.round] }

IDK.new(functions, width, height, 31).run
