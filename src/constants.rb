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

module Graphics
  include MiniGL

  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  SCALE = 2
  TILE_SIZE = 40

  def self.init_font
    @font = ImageFont.new(:font_font, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÁÉÍÓÚÀÃÕÂÊÔÑÇáéíóúàãõâêôñç0123456789.,:;!?¡¿/\\()[]+-%'\"←→∞$ĞğİıÖöŞşÜüĈĉĜĝĤĥĴĵŜŝŬŭ",
                          [5, 5, 5, 5, 5, 5, 5, 5, 1, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
                           5, 5, 5, 5, 5, 3, 5, 5, 1, 3, 4, 2, 7, 5, 5, 5, 5, 4, 5, 3, 5, 5, 7, 5, 5, 5,
                           5, 5, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
                           6, 4, 6, 6, 6, 6, 6, 6, 6, 6, 2, 3, 2, 3, 2, 6, 2, 6, 5, 5, 3, 3, 3, 3, 6, 4, 6, 2, 4, 8, 8,
                           10, 6, 6, 6, 2, 2, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 6, 6, 6, 6], 11, 3, 1)
  end

  def self.font
    @font
  end
end

Vector = MiniGL::Vector
