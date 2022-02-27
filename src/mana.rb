require_relative 'constants'
require_relative 'utils'
require_relative 'particles'

class Mana
  ANIM_CYCLE = 120

  attr_reader :bounds, :dead

  def initialize(x, y)
    @x = x + 8
    @y = y + 8
    @w = 24
    @h = 24
    @x_c = @x + @w / 2
    @y_c = @y + @h / 2
    @bounds = Rectangle.new(@x, @y, @w, @h)

    @particles = Particles.new(:glow, @x - 5, @y - 5, Color::LIME, 5, 2, nil, Vector.new(@w + 10, @h + 10), 2)
    @particles.start
    @timer = 0
  end

  def update(man)
    @timer += 1
    @timer = 0 if @timer == ANIM_CYCLE
    @particles.update

    return unless man.bounds.intersect?(bounds)

    man.add_mana(1)
    @dead = true
  end

  def draw
    rate = Utils.alternating_rate(@timer, ANIM_CYCLE)
    c1 = Utils.lighten(Color::LIME, 0.5 + rate * 0.4)
    c2 = Utils.lighten(Color::LIME, rate * 0.5)
    c3 = Utils.darken(Color::LIME, 0.1 - rate * 0.07)
    G.window.draw_triangle(@x_c, @y_c, c1, @x, @y_c, c1, @x_c, @y, c1, 0)
    G.window.draw_triangle(@x_c, @y_c, c2, @x + @w, @y_c, c2, @x_c, @y, c2, 0)
    G.window.draw_triangle(@x_c, @y_c, c2, @x, @y_c, c2, @x_c, @y + @h, c2, 0)
    G.window.draw_triangle(@x_c, @y_c, c3, @x + @w, @y_c, c3, @x_c, @y + @h, c3, 0)

    @particles.draw
  end
end
