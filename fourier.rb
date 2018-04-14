module Fourier
  extend self
  extend Math
  include Math

  def to(fx)
    n = fx.length
    n.times.map do |u|
      real = imaginary = 0
      fx.each_with_index do |(f_real, f_imaginary), k|
        p = -2*PI*u*k/n
        c, s = cos(p), sin(p)
        real      += c*f_real      + s*f_imaginary
        imaginary += c*f_imaginary - s*f_real
      end
      [real/n, imaginary/n]
    end
  end

  def from(fu, m=fu.length)
    n  = fu.length
    n.times.map do |k|
      real = imaginary = 0
      fu.take(m).each_with_index do |(f_real, f_imaginary), u|
        p = 2*PI*u*k/n
        c, s = cos(p), sin(p)
        real      += c*f_real      + s*f_imaginary
        imaginary += c*f_imaginary - s*f_real
      end
      [real, imaginary]
    end
  end
end
