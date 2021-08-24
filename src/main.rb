require 'minigl'
require_relative 'screen'
require_relative 'man'

include MiniGL

class Window < GameWindow
  def initialize
    super(800, 600, false)

    @screen = Screen.new
    @man = Man.new(0, 0)
  end

  def update
    KB.update
    @man.update(@screen)
  end

  def draw_circle(x, y, diam, color, detail = 12)
    r = diam / 2.0
    c_x = x + r
    c_y = y + r
    d_f = detail.to_f
    (0...detail).each do |i|
      a1 = i / d_f * 2 * Math::PI
      a2 = (i + 1) / d_f * 2 * Math::PI
      x1 = c_x + r * Math.cos(a1)
      y1 = c_y + r * Math.sin(a1)
      x2 = c_x + r * Math.cos(a2)
      y2 = c_y + r * Math.sin(a2)
      draw_triangle(c_x, c_y, color, x1, y1, color, x2, y2, color, 0)
    end
  end

  def draw
    clear Color::WHITE
    @screen.draw
    @man.draw
  end
end

Window.new.show
