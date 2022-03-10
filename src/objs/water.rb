require_relative '../obj'

include MiniGL

class Water < Obj
  ANIM_INTERVAL = 12

  def initialize(x, y, w, h)
    super(x, y, w, h, [:liquid])
    @img = Res.tileset('1', 20, 20)[2..4]
    @img_index = 0
    @timer = 0
  end

  def update
    super

    @timer += 1
    if @timer == ANIM_INTERVAL
      @img_index = (@img_index + 1) % 2
      @timer = 0
    end
  end

  def draw
    x_count = @w / Graphics::TILE_SIZE
    y_count = @h / Graphics::TILE_SIZE
    (0...x_count).each do |i|
      @img[@img_index].draw(@x + i * Graphics::TILE_SIZE, @y, 1, Graphics::SCALE, Graphics::SCALE)
    end
    (0...x_count).each do |i|
      (1...y_count).each do |j|
        @img[2].draw(@x + i * Graphics::TILE_SIZE, @y + j * Graphics::TILE_SIZE, 1, Graphics::SCALE, Graphics::SCALE)
      end
    end

    super
  end
end
