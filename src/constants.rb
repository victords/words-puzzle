module Color
  BLACK = 0xff000000
  WHITE = 0xffffffff
  LIME = 0xff00ff00
  RED = 0xffff0000
  DARK_BLUE = 0xff000099
  BEIGE = 0xffffee80
  GRAY = 0xff999999
  GOLD = 0xffffdd00
  MAGENTA = 0xffff00ff
end

module Physics
  MAN_WIDTH = 36
  MAN_HEIGHT = 96
  LIQUID_GRAVITY_SCALE = 0.4
  STICKY_ACCEL_SCALE = 0.3
end

module Game
  INITIAL_MAX_MANA = 3
  BG_MAP = {
    1 => 1,
    2 => 1,
    3 => 1,
  }.freeze
end

class Graphics
  include MiniGL

  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  SCALE = 2
  TILE_SIZE = 40

  class << self
    attr_reader :font, :text_helper

    def init_font
      @font = ImageFont.new(:font_font, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÁÉÍÓÚÀÃÕÂÊÔÑÇáéíóúàãõâêôñç0123456789.,:;!?¡¿/\\()[]+-%'\"←→∞$ĞğİıÖöŞşÜüĈĉĜĝĤĥĴĵŜŝŬŭ",
                            [5, 5, 5, 5, 5, 5, 5, 5, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
                             5, 5, 5, 5, 5, 3, 5, 5, 1, 3, 4, 2, 7, 5, 5, 5, 5, 4, 5, 3, 5, 5, 7, 5, 5, 5,
                             5, 5, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
                             5, 3, 5, 5, 5, 5, 5, 5, 5, 5, 1, 2, 1, 2, 1, 5, 1, 5, 4, 4, 2, 2, 2, 2, 5, 3, 5, 1, 3, 7, 7,
                             9, 5, 5, 5, 1, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 5, 5, 5, 5], 11, 3, 1)
      @text_helper = TextHelper.new(@font, Graphics::SCALE, Graphics::SCALE)
    end
  end
end

Vector = MiniGL::Vector
