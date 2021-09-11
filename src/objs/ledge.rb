require_relative '../obj'
require_relative '../constants'

include MiniGL

class Ledge < Obj
  COLOR1 = 0xff505050
  COLOR2 = 0xff808080
  BASE_WIDTH = 50
  BASE_HEIGHT = 20
  HEIGHT_INCREMENT = 5

  def initialize(x, y, w, h, props)
    super(x, y, w, h, props, [:semisolid])
  end

  def draw
    n = @w / BASE_WIDTH
    w = @w / n.to_f
    half = (n - 1) / 2.0
    (0...n).each do |i|
      h = BASE_HEIGHT + (half - (i - half).abs) * HEIGHT_INCREMENT
      G.window.draw_rect(@x + i * w, @y, w, h, COLOR1)
      G.window.draw_rect(@x + i * w + 2, @y + 2, w - 4, h - 4, COLOR2)
    end

    super
  end
end
