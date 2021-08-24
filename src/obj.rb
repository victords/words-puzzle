require 'set'
require_relative 'constants'

include MiniGL

class Obj
  attr_reader :x, :y, :w, :h

  DEFAULT_PROPS = {
    wall: Set[:solid],
    ledge: Set[:semisolid],
    water: Set[:liquid]
  }.freeze

  WAVE_SIZE = 30

  def initialize(type, x, y, w, h)
    @type = type
    @x = x
    @y = y
    @w = w
    @h = h

    @props = DEFAULT_PROPS[type].clone || Set.new

    @timer = 0
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

  def update
    if @type == :water
      @timer += 1
      @timer = 0 if @timer == WAVE_SIZE * 2
    end
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
    when :water
      G.window.draw_quad(@x, @y, Color::WATER,
                         @x + @w, @y, Color::WATER,
                         @x, @y + @h, Color::WATER,
                         @x + @w, @y + @h, Color::WATER, 0)
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
                               @x, @y - y, Color::WATER, 0)
          else
            y = (WAVE_SIZE - @x + x) * 0.5
            G.window.draw_triangle(@x, @y, Color::WATER,
                                   x + WAVE_SIZE, @y, Color::WATER,
                                   @x, @y - y, Color::WATER, 0)
          end
        elsif x + WAVE_SIZE > @x + @w
          if i.even?
            y = (@x + @w - x) * 0.5
            G.window.draw_triangle(x, @y, Color::WATER,
                                   @x + @w, @y, Color::WATER,
                                   @x + @w, @y - y, Color::WATER, 0)
          else
            y = (x + WAVE_SIZE - @x - @w) * 0.5
            G.window.draw_quad(x, @y, Color::WATER,
                               @x + @w, @y, Color::WATER,
                               @x + @w, @y - y, Color::WATER,
                               x, @y - WAVE_SIZE * 0.5, Color::WATER, 0)
          end
        else
          top_x = i.even? ? x + WAVE_SIZE : x
          G.window.draw_triangle(x, @y, Color::WATER,
                                 x + WAVE_SIZE, @y, Color::WATER,
                                 top_x, @y - WAVE_SIZE * 0.5, Color::WATER, 0)
        end
      end
    end
  end
end