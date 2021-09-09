require_relative '../obj'
require_relative '../constants'

include MiniGL

class Floor < Obj
  def initialize(x, y, w, h, props)
    super(x, y, w, h, props, [:solid])
  end

  def draw
    G.window.draw_rect(@x, @y, @w, @h, Color::BROWN)
    super
  end
end
