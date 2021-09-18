require_relative '../obj'

include MiniGL

class Water < Obj
  WAVE_SIZE = 20
  COLOR1 = [0x50ccffff, 0x500066ff]
  COLOR2 = [0x5099cccc, 0x50003399]

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
    wave_count = (@w.to_f / WAVE_SIZE).ceil
    (0..1).each do |i|
      G.window.draw_rect(@x, @y, @w, @h, COLOR1[i], COLOR2[i], false, 1)
      (-2..wave_count).each do |j|
        x = @x + (i + j) * WAVE_SIZE + (i.zero? ? @timer : -@timer)
        next if x + WAVE_SIZE < @x || x >= @x + @w
        if x < @x
          if j.even?
            y = (@x - x) * 0.5
            G.window.draw_quad(@x, @y, COLOR1[i],
                               x + WAVE_SIZE, @y, COLOR1[i],
                               x + WAVE_SIZE, @y - WAVE_SIZE * 0.5, COLOR1[i],
                               @x, @y - y, COLOR1[i], 1)
          else
            y = (WAVE_SIZE - @x + x) * 0.5
            G.window.draw_triangle(@x, @y, COLOR1[i],
                                   x + WAVE_SIZE, @y, COLOR1[i],
                                   @x, @y - y, COLOR1[i], 1)
          end
        elsif x + WAVE_SIZE > @x + @w
          if j.even?
            y = (@x + @w - x) * 0.5
            G.window.draw_triangle(x, @y, COLOR1[i],
                                   @x + @w, @y, COLOR1[i],
                                   @x + @w, @y - y, COLOR1[i], 1)
          else
            y = (x + WAVE_SIZE - @x - @w) * 0.5
            G.window.draw_quad(x, @y, COLOR1[i],
                               @x + @w, @y, COLOR1[i],
                               @x + @w, @y - y, COLOR1[i],
                               x, @y - WAVE_SIZE * 0.5, COLOR1[i], 1)
          end
        else
          top_x = j.even? ? x + WAVE_SIZE : x
          G.window.draw_triangle(x, @y, COLOR1[i],
                                 x + WAVE_SIZE, @y, COLOR1[i],
                                 top_x, @y - WAVE_SIZE * 0.5, COLOR1[i], 1)
        end
      end
    end

    super
  end
end
