require_relative '../obj'

include MiniGL

class Floor < Obj
  COLOR1 = 0xff333333
  COLOR2 = 0xff505050

  def initialize(x, y, w, h)
    super(x, y, w, h, [:solid])
    @img = Res.tileset('1', 20, 20)[0]
  end

  def draw
    x_count = @w / Graphics::TILE_SIZE
    y_count = @h / Graphics::TILE_SIZE
    (0...x_count).each do |i|
      (0...y_count).each do |j|
        @img.draw(@x + i * Graphics::TILE_SIZE, @y + j * Graphics::TILE_SIZE, 0, Graphics::SCALE, Graphics::SCALE)
      end
    end

    super
  end
end
