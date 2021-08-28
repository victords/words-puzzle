require_relative 'constants'

include MiniGL

class Text
  class << self
    def init
      @font = {}
      File.open("#{Res.prefix}font") do |f|
        f.each_line do |l|
          data = l.chomp.split(':')
          @font[data[0]] = {
            width: data[1].to_f,
            lines: data[2].split(';').map{|s| s.split(',').map(&:to_f)}
          }
          @font[data[0]][:lines] += @font[data[3]][:lines] if data[3]
        end
      end
    end

    def draw(text, x, y, size, color = Color::BLACK_A, thickness = 2)
      space_width = size * 0.1
      text.each_char do |c|
        next unless @font[c]
        v = MiniGL::Vector.new
        width = @font[c][:width] * 0.6 * size
        @font[c][:lines].each do |l|
          e1 = Vector.new(x + width * l[0], y + size * l[1])
          e2 = Vector.new(x + width * l[2], y + size * l[3])
          v = e2 - e1
          d = Math.sqrt(v.x * v.x + v.y * v.y)
          o = v.rotate(Math::PI * 0.5) / d * thickness * 0.5
          p1 = e1 + o
          p2 = e1 - o
          p3 = e2 + o
          p4 = e2 - o
          G.window.draw_quad(p1.x, p1.y, color,
                             p2.x, p2.y, color,
                             p3.x, p3.y, color,
                             p4.x, p4.y, color, 0)
        end
        x += width + space_width
      end
    end
  end
end
