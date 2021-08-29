module Color
  BLACK = 0xff000000
  WHITE = 0xffffffff
  BROWN = 0xff996600
  LIME = 0xff00ff00
  RED = 0xffff0000
  WATER = 0x8066ccff
  DARK_BLUE = 0xff000099
  BEIGE = 0xffffee80
  BLACK_TRANSP = 0
end

module Physics
  LIQUID_GRAVITY_SCALE = 0.33
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
