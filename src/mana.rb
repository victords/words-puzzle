require_relative 'constants'
require_relative 'utils'

class Mana
  ANIM_CYCLE = 120

  attr_reader :bounds, :dead

  def initialize(x, y)
    @x = x
    @y = y
    @w = 24
    @h = 24
    @bounds = Rectangle.new(@x, @y, @w, @h)

    @timer = 0
  end

  def update(man)
    @timer += 1
    @timer = 0 if @timer == ANIM_CYCLE

    return unless man.bounds.intersect?(bounds)

    man.add_mana(1)
    @dead = true
  end

  def draw
    rate = Utils.alternating_rate(@timer, ANIM_CYCLE)
    c1 = Utils.lighten(Color::LIME, 0.5 + rate * 0.4)
    c2 = Utils.lighten(Color::LIME, rate * 0.5)
    c3 = Utils.darken(Color::LIME, 0.1 - rate * 0.07)
    G.window.draw_triangle(@x, @y, c1, @x - @w / 2, @y, c1, @x, @y - @h / 2, c1, 0)
    G.window.draw_triangle(@x, @y, c2, @x + @w / 2, @y, c2, @x, @y - @h / 2, c2, 0)
    G.window.draw_triangle(@x, @y, c2, @x - @w / 2, @y, c2, @x, @y + @h / 2, c2, 0)
    G.window.draw_triangle(@x, @y, c3, @x + @w / 2, @y, c3, @x, @y + @h / 2, c3, 0)
  end
end
