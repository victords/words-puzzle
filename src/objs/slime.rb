require_relative '../obj'

class Slime < Obj
  def initialize(x, y, w, h)
    super(x, y, w, h, [:sticky, :solid])
    @tiles = Res.tileset('1', 20, 20)
    @cols = @w / Graphics::TILE_SIZE
    @rows = @h / Graphics::TILE_SIZE
  end

  def draw
    sc = Graphics::SCALE
    t_s = Graphics::TILE_SIZE
    if @cols > 1
      if @rows > 1
        @tiles[8].draw(@x, @y, 0, sc, sc)
        (1...(@cols - 1)).each { |i| @tiles[9].draw(@x + i * t_s, @y, 0, sc, sc) }
        @tiles[10].draw(@x + (@cols - 1) * t_s, @y, 0, sc, sc)

        (1...(@rows - 1)).each do |j|
          @tiles[16].draw(@x, @y + j * t_s, 0, sc, sc)
          (1...(@cols - 1)).each { |i| @tiles[17].draw(@x + i * t_s, @y + j * t_s, 0, sc, sc) }
          @tiles[18].draw(@x + (@cols - 1) * t_s, @y + j * t_s, 0, sc, sc)
        end

        @tiles[24].draw(@x, @y + (@rows - 1) * t_s, 0, sc, sc)
        (1...(@cols - 1)).each { |i| @tiles[25].draw(@x + i * t_s, @y + (@rows - 1) * t_s, 0, sc, sc) }
        @tiles[26].draw(@x + (@cols - 1) * t_s, @y + (@rows - 1) * t_s, 0, sc, sc)
      else
        @tiles[12].draw(@x, @y, 0, sc, sc)
        (1...(@cols - 1)).each { |i| @tiles[13].draw(@x + i * t_s, @y, 0, sc, sc) }
        @tiles[14].draw(@x + (@cols - 1) * t_s, @y, 0, sc, sc)
      end
    elsif @rows > 1
      @tiles[11].draw(@x, @y, 0, sc, sc)
      (1...(@rows - 1)).each { |i| @tiles[19].draw(@x, @y + i * t_s, 0, sc, sc) }
      @tiles[27].draw(@x, @y + (@rows - 1) * t_s, 0, sc, sc)
    else
      @tiles[15].draw(@x, @y, 0, sc, sc)
    end
  end
end
