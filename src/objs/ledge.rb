require_relative '../obj'
require_relative '../constants'

include MiniGL

class Ledge < Obj
  COLOR1 = 0xff505050
  COLOR2 = 0xff808080
  BASE_WIDTH = 50
  BASE_HEIGHT = 20
  HEIGHT_INCREMENT = 5

  def initialize(x, y, w, h)
    super(x, y, w, h, [:semisolid])
  end

  def draw(x_offset = 0, y_offset = 0)
    n = @w / BASE_WIDTH
    w = @w / n.to_f
    half = (n - 1) / 2.0
    (0...n).each do |i|
      h = BASE_HEIGHT + (half - (i - half).abs) * HEIGHT_INCREMENT
      G.window.draw_rect(@x + i * w + x_offset, @y + y_offset, w, h, COLOR1)
      G.window.draw_rect(@x + i * w + 2 + x_offset, @y + 2 + y_offset, w - 4, h - 4, COLOR2)
    end

    super()
  end
end
