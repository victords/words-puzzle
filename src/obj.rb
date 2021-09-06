require 'set'
require_relative 'constants'
require_relative 'particles'
require_relative 'utils'

include MiniGL

class Obj
  attr_reader :type, :x, :y, :w, :h

  DEFAULT_PROPS = {
    floor: [:solid],
    wall: [:solid],
    ledge: [:semisolid],
    water: [:liquid]
  }.freeze

  EXCLUSIVE_PROPS = {
    solid: [:semisolid, :liquid],
    semisolid: [:solid, :liquid],
    liquid: [:solid, :semisolid]
  }.freeze

  WAVE_SIZE = 20
  HIGHLIGHT_CYCLE = 120

  def initialize(type, x, y, w, h, props)
    @type = type
    @x = x
    @y = y
    @w = w
    @h = h

    @props = Set.new(DEFAULT_PROPS[type]) + (props || [])
    @original_props = @props.clone

    @timer = @highlight_timer = 0
    @particles = Particles.new(:star, @x, @y, Color::MAGENTA, @w * @h / 200.0, 1, nil, Vector.new(@w, @h), 1, 1)
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
    if @type == :water
      @timer += 1
      @timer = 0 if @timer == WAVE_SIZE * 2
    end
    @particles.update

    return unless @highlight

    @highlight_timer += 1
    @highlight_timer = 0 if @highlight_timer == HIGHLIGHT_CYCLE
  end

  def draw
    case @type
    when :wall, :floor
      color = @type == :wall ? Color::BLACK : Color::BROWN
      G.window.draw_rect(@x, @y, @w, @h, color)
    when :ledge
      G.window.draw_rect(@x, @y, @w, @h, Color::BLACK, Color::BLACK_TRANSP)
    when :water
      G.window.draw_rect(@x, @y, @w, @h, Color::WATER, nil, false, 1)
      wave_count = (@w.to_f / WAVE_SIZE).ceil
      (-2...wave_count).each do |i|
        x = @x + i * WAVE_SIZE + @timer
        next if x + WAVE_SIZE < @x || x >= @x + @w
        if x < @x
          if i.even?
            y = (@x - x) * 0.5
            G.window.draw_quad(@x, @y, Color::WATER,
                               x + WAVE_SIZE, @y, Color::WATER,
                               x + WAVE_SIZE, @y - WAVE_SIZE * 0.5, Color::WATER,
                               @x, @y - y, Color::WATER, 1)
          else
            y = (WAVE_SIZE - @x + x) * 0.5
            G.window.draw_triangle(@x, @y, Color::WATER,
                                   x + WAVE_SIZE, @y, Color::WATER,
                                   @x, @y - y, Color::WATER, 1)
          end
        elsif x + WAVE_SIZE > @x + @w
          if i.even?
            y = (@x + @w - x) * 0.5
            G.window.draw_triangle(x, @y, Color::WATER,
                                   @x + @w, @y, Color::WATER,
                                   @x + @w, @y - y, Color::WATER, 1)
          else
            y = (x + WAVE_SIZE - @x - @w) * 0.5
            G.window.draw_quad(x, @y, Color::WATER,
                               @x + @w, @y, Color::WATER,
                               @x + @w, @y - y, Color::WATER,
                               x, @y - WAVE_SIZE * 0.5, Color::WATER, 1)
          end
        else
          top_x = i.even? ? x + WAVE_SIZE : x
          G.window.draw_triangle(x, @y, Color::WATER,
                                 x + WAVE_SIZE, @y, Color::WATER,
                                 top_x, @y - WAVE_SIZE * 0.5, Color::WATER, 1)
        end
      end
    end

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
