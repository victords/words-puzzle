require_relative 'constants'

include MiniGL

class Obj
  DEFAULT_PROPS = {
    wall: [:solid],
  }.freeze

  attr_reader :type, :x, :y, :w, :h

  def initialize(type, x, y, w, h)
    @type = type
    @x = x
    @y = y
    @w = w
    @h = h

    @props = [] + DEFAULT_PROPS[type]
  end

  def method_missing(symbol)
    if symbol.to_s.end_with?('?')
      @props.include?(symbol.to_s.chop.to_sym)
    end
  end

  def respond_to_missing?
    true
  end

  def draw
    case @type
    when :wall
      G.window.draw_quad(@x, @y, Color::BLACK_A,
                         @x + @w, @y, Color::BLACK_A,
                         @x, @y + @h, Color::BLACK_A,
                         @x + @w, @y + @h, Color::BLACK_A, 0)
    end
  end
end
