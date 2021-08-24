require 'set'
require_relative 'constants'

include MiniGL

class Obj
  attr_reader :x, :y, :w, :h

  DEFAULT_PROPS = {
    wall: Set[:solid],
    ledge: Set[:semisolid],
  }.freeze

  def initialize(type, x, y, w, h)
    @type = type
    @x = x
    @y = y
    @w = w
    @h = h

    @props = DEFAULT_PROPS[type].clone || Set.new
  end

  def add_prop(prop)
    @props << prop
  end

  def passable
    semisolid?
  end

  def bounds
    Rectangle.new(@x, @y, @w, @h)
  end

  def method_missing(method_name)
    @props.include?(method_name.to_s.chop.to_sym)
  end

  def respond_to_missing?(method_name, _ = false)
    method_name.to_s.end_with?('?')
  end

  def draw
    case @type
    when :wall
      G.window.draw_quad(@x, @y, Color::BLACK_A,
                         @x + @w, @y, Color::BLACK_A,
                         @x, @y + @h, Color::BLACK_A,
                         @x + @w, @y + @h, Color::BLACK_A, 0)
    when :ledge
      G.window.draw_quad(@x, @y, Color::BLACK_A,
                         @x + @w, @y, Color::BLACK_A,
                         @x, @y + @h, Color::BLACK_TRANSP,
                         @x + @w, @y + @h, Color::BLACK_TRANSP, 0)
    when :none
      G.window.draw_quad(@x, @y, Color::RED_A,
                         @x + @w, @y, Color::RED_A,
                         @x, @y + @h, Color::RED_A,
                         @x + @w, @y + @h, Color::RED_A, 0)
    end
  end
end
