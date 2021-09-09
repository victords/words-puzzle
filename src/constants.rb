module Color
  BLACK = 0xff000000
  WHITE = 0xffffffff
  BROWN = 0xff996600
  LIME = 0xff00ff00
  RED = 0xffff0000
  DARK_BLUE = 0xff000099
  BEIGE = 0xffffee80
  GRAY = 0xff999999
  GOLD = 0xffffdd00
  MAGENTA = 0xffff00ff
end

module Physics
  MAN_WIDTH = 32
  MAN_HEIGHT = 64
  LIQUID_GRAVITY_SCALE = 0.4
end

module Game
  SCREEN_WIDTH = 1280
  SCREEN_HEIGHT = 720
  INITIAL_MAX_MANA = 3
  BG_MAP = {
    1 => 1,
    2 => 1,
    3 => 1,
  }.freeze
end
