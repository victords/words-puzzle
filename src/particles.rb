require_relative 'utils'

include MiniGL

class Particles
  FRAMES_PER_SECOND = 60
  FRAME_DURATION = 1.0 / FRAMES_PER_SECOND

  attr_reader :playing, :x, :y

  def initialize(type, x, y, color, emission_rate, duration, spread_rate = 10, area = nil, scale = 1, z_index = 0)
    @type = type
    @sprite_cols, @sprite_rows, @indices =
      case type
      when :glow
        [3, 1, [0, 1, 2, 1]]
      when :star
        [1, 1, [0]]
      end
    @x = x
    @y = y
    @color = color
    @emission_interval = 1.0 / emission_rate
    @duration = duration * FRAMES_PER_SECOND
    @spread_rate = spread_rate
    @area = area
    @scale = scale
    @z_index = z_index

    @elements = []
    @timer = 0
    @playing = false
  end

  def update
    @elements.reverse_each do |e|
      e.update
      @elements.delete(e) if e.dead
    end

    return unless @playing

    @timer += FRAME_DURATION
    if @timer >= @emission_interval
      x = @area ? @x + rand * @area.x : @x + @spread_rate * (rand - 0.5)
      y = @area ? @y + rand * @area.y : @y + @spread_rate * (rand - 0.5)
      img = Res.imgs("fx_#{@type}", @sprite_cols, @sprite_rows)
      x -= img[0].width * Graphics::SCALE / 2
      y -= img[0].height * Graphics::SCALE / 2
      @elements << Effect.new(x, y, "fx_#{@type}", @sprite_cols, @sprite_rows, @duration / @indices.size, @indices)
      @timer -= @emission_interval
    end
  end

  def move(x, y)
    @x = x; @y = y
  end

  def start
    @playing = true
  end

  def stop
    @playing = false
    @timer = 0
  end

  def draw
    return unless @playing

    @elements.each do |e|
      alpha = (Utils.alternating_rate(e.elapsed_time, @duration) * 255).round
      e.draw(nil, Graphics::SCALE, Graphics::SCALE, alpha, @color & 0xffffff, @z_index)
    end
  end
end
