require_relative '../obj'
require_relative '../animation'

class Spring < Obj
  include Animation

  def initialize(x, y, w, h)
    super(x, y, w, h, [:bouncy, :semisolid])
    @img = Res.imgs(:sprite_spring, 3, 1)
    @img_index = 0
  end

  def update(man)
    if @animating
      animate_once([0, 1, 2, 1, 0, 1, 0], 5) do
        @animating = false
      end
    end
    return unless man.bottom == self && man.speed.y.zero?

    set_animation(0)
    @animating = true
  end

  def draw
    h_scale = Graphics::SCALE * @w / Graphics::TILE_SIZE
    @img[@img_index].draw(@x, @y, 0, h_scale, Graphics::SCALE)

    super
  end
end
