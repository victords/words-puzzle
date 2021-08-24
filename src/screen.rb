require_relative 'obj'

include MiniGL

class Screen
  def initialize
    @objects = [
      Obj.new(:wall, 0, 560, 800, 40)
    ]
  end

  def get_obstacles
    @objects.select { |o| o.solid? }.map { |o| Block.new(o.x, o.y, o.w, o.h) }
  end

  def draw
    @objects.each(&:draw)
  end
end
