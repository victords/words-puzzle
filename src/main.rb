require 'minigl'
require_relative 'screen'
require_relative 'man'
require_relative 'hud'
require_relative 'word'

include MiniGL

class Window < GameWindow
  def initialize
    super(Graphics::SCREEN_WIDTH, Graphics::SCREEN_HEIGHT)

    Res.prefix = File.expand_path(__FILE__).split('/')[0..-3].join('/') + '/data'
    Res.retro_images = true
    Graphics.init_font

    @hud = Hud.new
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
    @screen.update(@man)
    @man.update(@screen)
    @hud.update
    toggle_fullscreen if KB.key_pressed?(Gosu::KB_F4)
    close if KB.key_pressed?(Gosu::KB_ESCAPE)
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
    @screen.draw
    @man.draw
    @hud.draw
  end
end

Window.new.show
