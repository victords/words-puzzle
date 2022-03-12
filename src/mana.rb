require_relative 'constants'
require_relative 'utils'
require_relative 'particles'

class Mana < MiniGL::GameObject
  attr_reader :dead

  def initialize(x, y)
    super(x + 8, y + 8, 24, 24, :sprite_mana)

    @particles = Particles.new(:glow, @x - 5, @y - 5, Color::LIME, 5, 2, nil, Vector.new(@w + 10, @h + 10))
    @particles.start
    @start_y = @y
    @cycle = 0
  end

  def update(man)
    @particles.update
    @cycle, @y = Utils.sinoid(@cycle, 2)
    @y += @start_y

    return unless man.bounds.intersect?(bounds)

    man.add_mana(1)
    @dead = true
  end

  def draw
    super(nil, Graphics::SCALE, Graphics::SCALE)
    @particles.draw
  end
end
