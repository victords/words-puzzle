module Color
  BLACK = 0
  WHITE = 0xffffff
  BLACK_A = 0xff000000
  WHITE_A = 0xffffffff
  BROWN_A = 0xff996600
  LIME_A = 0xff00ff00
  BLACK_TRANSP = 0
  WHITE_TRANSP = 0x00ffffff
  RED_A = 0xffff0000
  WATER = 0x8066ccff
end

module Physics
  LIQUID_GRAVITY_SCALE = 0.33
end

module Game
  SCREEN_WIDTH = 1366
  SCREEN_HEIGHT = 768
  INITIAL_MAX_MANA = 3
  BG_MAP = {
    1 => 1,
    2 => 1,
    3 => 1,
  }.freeze
end
