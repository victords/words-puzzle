include MiniGL

class Particles
  Particle = Struct.new(:x, :y, :lifetime)

  FRAME_DURATION = 1.0 / 60

  def initialize(type, x, y, color, emission_rate, duration, spread_rate = 10, scale = 1, z_index = 0)
    @type = type
    @x = x
    @y = y
    @color = color
    @emission_interval = 1.0 / emission_rate
    @duration = duration
    @spread_rate = spread_rate
    @scale = scale
    @z_index = z_index

    @elements = []
    @timer = 0
  end

  def update
    @elements.reverse_each do |e|
      e.lifetime -= FRAME_DURATION
      @elements.delete(e) if e.lifetime <= 0
    end

    return if @stopped

    @timer += FRAME_DURATION
    if @timer >= @emission_interval
      @elements << Particle.new(@x + @spread_rate * (rand - 0.5), @y + @spread_rate * (rand - 0.5), @duration)
      @timer -= @emission_interval
    end
  end

  def move(x, y)
    @x = x; @y = y
  end

  def start
    @stopped = false
  end

  def stop
    @stopped = true
    @timer = 0
  end

  def draw
    @elements.each do |e|
      alpha = ((e.lifetime <= @duration * 0.5 ? e.lifetime : (@duration - e.lifetime)) / (@duration * 0.5) * 255).round
      color = (alpha << 24) | (@color & 0xffffff)
      case @type
      when :glow
        G.window.draw_line(e.x, e.y - @scale, color, e.x, e.y + @scale + 1, color, @z_index)
        G.window.draw_line(e.x - @scale, e.y, color, e.x + @scale + 1, e.y, color, @z_index)
      end
    end
  end
end
