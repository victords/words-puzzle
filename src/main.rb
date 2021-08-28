require 'minigl'
require_relative 'screen'
require_relative 'man'
require_relative 'hud'

include MiniGL

class Window < GameWindow
  def initialize
    super(Game::SCREEN_WIDTH, Game::SCREEN_HEIGHT, false)

    Res.prefix = File.expand_path(__FILE__).split('/')[0..-3].join('/') + '/data'

    @hud = Hud.new(Game::INITIAL_MAX_MANA)

    @man = Man.new
    @man.on_leave = method(:handle_leave)
    @man.on_mana_change = @hud.method(:update_mana)

    @screen_cache = {}
    load_screen(1)
  end

  def load_screen(num, entrance = nil)
    if @screen_cache.has_key?(num)
      @screen = @screen_cache[num]
      @screen.reset
    else
      @screen = @screen_cache[num] = Screen.new(num)
    end
    @man.set_position(@screen.entrance(entrance))
  end

  def handle_leave(dir)
    load_screen(@screen.exit(dir), dir)
  end

  def update
    KB.update
    @screen.update
    @man.update(@screen)

    toggle_fullscreen if KB.key_pressed?(Gosu::KB_F4)
  end

  def draw_circle(x, y, diam, color, detail = nil)
    detail ||= 12
    r = diam / 2.0
    c_x = x + r
    c_y = y + r
    d_f = detail.to_f
    (0...detail).each do |i|
      a1 = i / d_f * 2 * Math::PI
      a2 = (i + 1) / d_f * 2 * Math::PI
      x1 = c_x + r * Math.cos(a1)
      y1 = c_y + r * Math.sin(a1)
      x2 = c_x + r * Math.cos(a2)
      y2 = c_y + r * Math.sin(a2)
      draw_triangle(c_x, c_y, color, x1, y1, color, x2, y2, color, 0)
    end
  end

  def draw
    clear @screen.bg_color
    @screen.draw
    @man.draw
    @hud.draw
  end
end

Window.new.show
