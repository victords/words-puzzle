require_relative '../obj'
require_relative '../constants'

include MiniGL

class Floor < Obj
  COLOR1 = 0xff663300
  COLOR2 = 0xff996600
  COLOR3 = 0xff805000

  def initialize(x, y, w, h, props)
    super(x, y, w, h, props, [:solid])
  end

  def draw
    G.window.draw_rect(@x, @y, @w, @h, COLOR1)
    G.window.draw_rect(@x + 2, @y + 2, @w - 4, @h - 4, COLOR2)
    cols = (@w - 6) / 15
    (0..cols).each do |i|
      (0..2).each do |j|
        size = 2 * (4 - j)
        offset = (10 - size) / 2
        x = @x + 3 + 15 * i + offset
        y = @y + 3 + 15 * j + offset
        G.window.draw_circle(x, y, size, COLOR3, size) if x + size <= @x + @w - 2 && y + size <= @y + @h - 2
        G.window.draw_circle(x + 7.5, y + 7.5, size, COLOR3, size) if x + size <= @x + @w - 9.5 && y + size <= @y + @h - 9.5
      end
    end
    super
  end
end
