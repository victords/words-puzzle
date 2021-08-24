require_relative 'obj'

include MiniGL

class Screen
  def initialize
    @objects = [
      Obj.new(:wall, 0, 560, 800, 40),
      Obj.new(:wall, 400, 380, 200, 40),
      Obj.new(:wall, 0, 0, 30, 600),
      Obj.new(:wall, 770, 0, 30, 600),
      Obj.new(:ledge, 150, 440, 180, 40),
      Obj.new(:none, 54, 232, 77, 31)
    ]
  end

  def get_obstacles
    @objects.select { |o| o.solid? || o.semisolid? }
  end

  def update
    @objects[2].add_prop(:sticky) if KB.key_pressed?(Gosu::KB_A)
  end

  def draw
    @objects.each(&:draw)
  end
end
