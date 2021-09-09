require_relative '../obj'

include MiniGL

class Wall < Obj
  COLOR1 = 0xff333333
  COLOR2 = 0xff505050
  COLOR3 = 0xff666666

  def initialize(x, y, w, h, props)
    super(x, y, w, h, props, [:solid])
  end

  def draw
    G.window.draw_rect(@x, @y, @w, @h, COLOR1)
    # h_count = (@w / 60).floor
    # v_count = (@h / 40).floor
    # (0...h_count).each do |i|
    #   (0...v_count).each do |j|
    #     next if (i + j).odd?
    #     G.window.draw_rect(@x + i * 60 + 10, @y + j * 40 + 10, 50, 30, COLOR2)
    #     G.window.draw_rect(@x + i * 60 + 5, @y + j * 40 + 5, 50, 30, COLOR3)
    #   end
    # end

    super
  end
end
