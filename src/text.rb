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

    def draw(text, x, y, size)
      space_width = size * 0.1
      text.each_char do |c|
        next unless @font[c]

        width = @font[c][:width] * 0.6 * size
        @font[c][:lines].each do |l|
          G.window.draw_line(x + width * l[0], y + size * l[1], Color::BLACK_A,
                             x + width * l[2], y + size * l[3], Color::BLACK_A, 0)
        end
        x += width + space_width
      end
    end
  end
end
