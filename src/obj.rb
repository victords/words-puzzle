require 'set'
require_relative 'constants'
require_relative 'particles'
require_relative 'utils'

include MiniGL

class Obj
  attr_reader :x, :y, :w, :h

  EXCLUSIVE_PROPS = {
    solid: [:semisolid, :liquid],
    semisolid: [:solid, :liquid],
    liquid: [:solid, :semisolid]
  }.freeze

  HIGHLIGHT_CYCLE = 120

  def initialize(x, y, w, h, default_props = [])
    @x = x
    @y = y
    @w = w
    @h = h

    @props = Set.new(default_props)
    @original_props = @props.clone

    @highlight_timer = 0
    @particles = Particles.new(:star, @x, @y, Color::MAGENTA, @w * @h / 200.0, 1, nil, Vector.new(@w, @h), 1, 1)
  end

  def type
    self.class.to_s.downcase.to_sym
  end

  def add_prop(prop)
    EXCLUSIVE_PROPS[prop]&.each { |p| @props.delete(p) }
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

  def reset
    @props = @original_props.clone
  end

  def highlight=(value)
    @highlight = value
    if @highlight
      @particles.start
    else
      @particles.stop
    end
  end

  def update
    @particles.update

    return unless @highlight

    @highlight_timer += 1
    @highlight_timer = 0 if @highlight_timer == HIGHLIGHT_CYCLE
  end

  def draw
    @particles.draw
    return unless @highlight

    alpha = 51 + (Utils.alternating_rate(@highlight_timer, HIGHLIGHT_CYCLE) * 102).round
    color1 = (alpha << 24) | (Color::MAGENTA & 0xffffff)
    color2 = ((alpha * 0.66667).round << 24) | (Color::MAGENTA & 0xffffff)
    color3 = ((alpha * 0.33333).round << 24) | (Color::MAGENTA & 0xffffff)
    G.window.draw_outline_rect(@x, @y, @w, @h, color1, 2, 1)
    G.window.draw_outline_rect(@x + 2, @y + 2, @w - 4, @h - 4, color2, 2, 1)
    G.window.draw_outline_rect(@x + 4, @y + 4, @w - 8, @h - 8, color3, 2, 1)
  end
end
