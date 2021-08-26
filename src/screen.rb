require_relative 'obj'

include MiniGL

class Screen
  def initialize
    @objects = [
      Obj.new(:wall, 0, 360, 600, 240),
      Obj.new(:wall, 600, 560, 200, 40),
      Obj.new(:wall, 400, 180, 200, 40, [:bouncy]),
      Obj.new(:wall, 0, 0, 30, 600, [:bouncy]),
      Obj.new(:wall, 770, 0, 30, 600),
      Obj.new(:ledge, 150, 240, 180, 40),
      Obj.new(:water, 600, 375, 170, 185)
    ]
  end

  def get_obstacles
    @objects.select { |o| o.solid? || o.semisolid? }
  end

  def inside_liquid?(obj)
    @objects.any? { |o| o != obj && o.liquid? && o.bounds.intersect?(obj.bounds) }
  end

  def update
    @objects.each(&:update)
  end

  def draw
    @objects.each(&:draw)
  end
end
