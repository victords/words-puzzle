require_relative '../obj'

include MiniGL

class Water < Obj
  WAVE_SIZE = 20
  COLOR = 0x8066ccff

  def initialize(x, y, w, h, props)
    super(x, y, w, h, props, [:liquid])

    @timer = 0
  end

  def update
    super

    @timer += 1
    @timer = 0 if @timer == WAVE_SIZE * 2
  end

  def draw
    G.window.draw_rect(@x, @y, @w, @h, COLOR, nil, false, 1)
    wave_count = (@w.to_f / WAVE_SIZE).ceil
    (-2...wave_count).each do |i|
      x = @x + i * WAVE_SIZE + @timer
      next if x + WAVE_SIZE < @x || x >= @x + @w
      if x < @x
        if i.even?
          y = (@x - x) * 0.5
          G.window.draw_quad(@x, @y, COLOR,
                             x + WAVE_SIZE, @y, COLOR,
                             x + WAVE_SIZE, @y - WAVE_SIZE * 0.5, COLOR,
                             @x, @y - y, COLOR, 1)
        else
          y = (WAVE_SIZE - @x + x) * 0.5
          G.window.draw_triangle(@x, @y, COLOR,
                                 x + WAVE_SIZE, @y, COLOR,
                                 @x, @y - y, COLOR, 1)
        end
      elsif x + WAVE_SIZE > @x + @w
        if i.even?
          y = (@x + @w - x) * 0.5
          G.window.draw_triangle(x, @y, COLOR,
                                 @x + @w, @y, COLOR,
                                 @x + @w, @y - y, COLOR, 1)
        else
          y = (x + WAVE_SIZE - @x - @w) * 0.5
          G.window.draw_quad(x, @y, COLOR,
                             @x + @w, @y, COLOR,
                             @x + @w, @y - y, COLOR,
                             x, @y - WAVE_SIZE * 0.5, COLOR, 1)
        end
      else
        top_x = i.even? ? x + WAVE_SIZE : x
        G.window.draw_triangle(x, @y, COLOR,
                               x + WAVE_SIZE, @y, COLOR,
                               top_x, @y - WAVE_SIZE * 0.5, COLOR, 1)
      end
    end

    super
  end
end
