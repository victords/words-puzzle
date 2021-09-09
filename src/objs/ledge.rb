require_relative '../obj'
require_relative '../constants'

include MiniGL

class Ledge < Obj
  def initialize(x, y, w, h, props)
    super(x, y, w, h, props, [:semisolid])
  end

  def draw
    G.window.draw_rect(@x, @y, @w, @h, Color::BLACK, 0)
    super
  end
end
