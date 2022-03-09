require_relative 'floor'

class Wall < Floor
  def initialize(x, y, w, h)
    super
    @img = Res.tileset('1', 20, 20)[1]
  end
end
