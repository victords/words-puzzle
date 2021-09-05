require_relative 'utils'

include MiniGL

class Particles
  Particle = Struct.new(:x, :y, :lifetime)

  FRAME_DURATION = 1.0 / 60

  def initialize(type, x, y, color, emission_rate, duration, spread_rate = 10, area = nil, scale = 1, z_index = 0)
    @type = type
    @x = x
    @y = y
    @color = color
    @emission_interval = 1.0 / emission_rate
    @duration = duration
    @spread_rate = spread_rate
    @area = area
    @scale = scale
    @z_index = z_index

    @elements = []
    @timer = 0
    @stopped = true
  end

  def update
    @elements.reverse_each do |e|
      e.lifetime -= FRAME_DURATION
      @elements.delete(e) if e.lifetime <= 0
    end

    return if @stopped

    @timer += FRAME_DURATION
    if @timer >= @emission_interval
      x = @area ? @x + rand * @area.x : @x + @spread_rate * (rand - 0.5)
      y = @area ? @y + rand * @area.y : @y + @spread_rate * (rand - 0.5)
      @elements << Particle.new(x, y, @duration)
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
      alpha = (Utils.alternating_rate(e.lifetime, @duration) * 255).round
      color = (alpha << 24) | (@color & 0xffffff)
      case @type
      when :glow
        G.window.draw_line(e.x, e.y - @scale, color, e.x, e.y + @scale + 1, color, @z_index)
        G.window.draw_line(e.x - @scale, e.y, color, e.x + @scale + 1, e.y, color, @z_index)
      when :star
        i_r = 5 * @scale
        o_r = 10 * @scale
        sides = 10
        last_a = last_x = last_y = nil
        (0...sides).each do |i|
          a1 = last_a || i / sides.to_f * 2 * Math::PI
          a2 = (i + 1) / sides.to_f * 2 * Math::PI
          x1 = last_x || e.x + (i.even? ? o_r : i_r) * Math.cos(a1)
          y1 = last_y || e.y + (i.even? ? o_r : i_r) * Math.sin(a1)
          x2 = e.x + (i.even? ? i_r : o_r) * Math.cos(a2)
          y2 = e.y + (i.even? ? i_r : o_r) * Math.sin(a2)
          G.window.draw_triangle(e.x, e.y, color, x1, y1, color, x2, y2, color, @z_index)
          last_a = a2
          last_x = x2
          last_y = y2
        end
      end
    end
  end
end
