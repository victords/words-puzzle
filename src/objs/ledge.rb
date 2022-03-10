require_relative '../obj'
require_relative '../constants'

include MiniGL

class Ledge < Obj
  def initialize(x, y, w, h)
    super(x, y, w, h, [:semisolid])
    @tiles = Res.tileset('1', 20, 20)
  end

  def draw
    n = @w / Graphics::TILE_SIZE
    (0...n).each do |i|
      tile_index = if n >= 5
                     if i >= 2 && i < n - 2
                       7
                     elsif i == 1 || i == n - 2
                       6
                     else
                       5
                     end
                   elsif n >= 3
                     if i >= 1 && i < n - 1
                       6
                     else
                       5
                     end
                   else
                     5
                   end
      @tiles[tile_index].draw(@x + i * Graphics::TILE_SIZE, @y, 0, Graphics::SCALE, Graphics::SCALE)
    end

    super
  end
end
