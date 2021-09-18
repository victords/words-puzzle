require_relative '../obj'

include MiniGL

class Wall < Obj
  COLOR1 = 0xff333333
  COLOR2 = 0xff505050

  def initialize(x, y, w, h, props)
    super(x, y, w, h, props, [:solid])
  end

  def draw(x_offset = 0, y_offset = 0)
    G.window.draw_rect(@x + x_offset, @y + y_offset, @w, @h, COLOR1)
    G.window.draw_rect(@x + 2 + x_offset, @y + 2 + y_offset, @w - 4, @h - 4, COLOR2)
    start_x = x = 50 * ((@x + 1) / 50)
    y = 30 * ((@y + 1) / 30)
    while y < @y + @h - 2
      G.window.draw_rect(@x + 2 + x_offset, y + y_offset, @w - 4, [2, @y + @h - 2 - y].min, Color::BLACK) if y >= @y + 2
      x += 25 if (y / 30).even?
      while x < @x + @w - 2
        h = y >= @y + 2 ? [30, @y + @h - 2 - y].min : y + 28 - @y
        G.window.draw_rect(x + x_offset, [y, @y + 2].max + y_offset, [2, @x + @w - 2 - x].min, h, Color::BLACK) if x >= @x + 2
        x += 50
      end
      x = start_x
      y += 30
    end

    super()
  end
end
