require 'set'
require_relative 'constants'

include MiniGL

class Obj
  attr_reader :type, :x, :y, :w, :h
  attr_accessor :highlight

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

  def update
    if @type == :water
      @timer += 1
      @timer = 0 if @timer == WAVE_SIZE * 2
    end

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

    return unless @highlight

    alpha = 51 + ((@highlight_timer <= HIGHLIGHT_CYCLE / 2 ? @highlight_timer : (HIGHLIGHT_CYCLE - @highlight_timer)).to_f / (HIGHLIGHT_CYCLE / 2) * 102).round
    color = (alpha << 24) | (Color::MAGENTA & 0xffffff)
    G.window.draw_rect(@x, @y, @w, @h * 0.5, color, Color::MAGENTA_TRANSP, false, 1)
    G.window.draw_rect(@x, @y + @h * 0.5, @w, @h * 0.5, Color::MAGENTA_TRANSP, color, false, 1)
    G.window.draw_rect(@x, @y, @w * 0.5, @h, color, Color::MAGENTA_TRANSP, true, 1)
    G.window.draw_rect(@x + @w * 0.5, @y, @w * 0.5, @h, Color::MAGENTA_TRANSP, color, true, 1)
  end
end
