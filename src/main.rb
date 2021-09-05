require 'minigl'
require_relative 'screen'
require_relative 'man'
require_relative 'hud'
require_relative 'text'

include MiniGL

class Window < GameWindow
  def initialize
    super(Game::SCREEN_WIDTH, Game::SCREEN_HEIGHT)

    Res.prefix = File.expand_path(__FILE__).split('/')[0..-3].join('/') + '/data'

    @hud = Hud.new(Game::INITIAL_MAX_MANA)

    @man = Man.new
    @man.on_leave = method(:handle_leave)
    @man.on_start_spell = lambda { |x, y, obj, prop|
      @hud.start_spell(x, y, obj.to_s, prop.to_s)
      @screen.highlight(obj)
    }
    @man.on_update_spell = lambda { |key, value|
      @hud.update_spell(key, value)
      @screen.highlight(value) if key == :obj
    }
    @man.on_cancel_spell = lambda {
      @hud.end_spell
      @screen.highlight(nil)
    }
    @man.on_cast_spell = lambda { |obj, prop|
      @hud.end_spell
      @screen.apply(obj, prop)
      @screen.highlight(nil)
    }
    @man.on_mana_change = @hud.method(:update_mana)

    @screen_cache = {}
    load_screen(1)

    Text.init
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
    @hud.update

    toggle_fullscreen if KB.key_pressed?(Gosu::KB_F4)
    close if KB.key_pressed?(Gosu::KB_ESCAPE)
  end

  def draw_circle(x, y, diam, color, detail = nil, z_index = 0)
    detail ||= 12
    r = diam / 2.0
    c_x = x + r
    c_y = y + r
    d_f = detail.to_f
    last_a = last_x = last_y = nil
    (0...detail).each do |i|
      a1 = last_a || i / d_f * 2 * Math::PI
      a2 = (i + 1) / d_f * 2 * Math::PI
      x1 = last_x || c_x + r * Math.cos(a1)
      y1 = last_y || c_y + r * Math.sin(a1)
      x2 = c_x + r * Math.cos(a2)
      y2 = c_y + r * Math.sin(a2)
      draw_triangle(c_x, c_y, color, x1, y1, color, x2, y2, color, z_index)
      last_a = a2
      last_x = x2
      last_y = y2
    end
  end

  def draw_rect(x, y, w, h, color, color2 = nil, horiz = false, z_index = 0)
    draw_quad(x, y, color,
              x + w, y, horiz ? (color2 || color) : color,
              x, y + h, horiz ? color : (color2 || color),
              x + w, y + h, color2 || color,
              z_index)
  end

  def draw_outline_rect(x, y, w, h, color, thickness = 1, z_index = 0)
    draw_rect(x, y, w, thickness, color, nil, nil, z_index)
    draw_rect(x, y + h - thickness, w, thickness, color, nil, nil, z_index)
    draw_rect(x, y + thickness, thickness, h - 2 * thickness, color, nil, nil, z_index)
    draw_rect(x + w - thickness, y + thickness, thickness, h - 2 * thickness, color, nil, nil, z_index)
  end

  def draw
    clear @screen.bg_color
    @screen.draw
    @man.draw
    @hud.draw
  end
end

Window.new.show
