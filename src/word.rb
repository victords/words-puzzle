require_relative 'constants'
require_relative 'utils'
require_relative 'text'

class Word
  FONT_SIZE = 50
  CYCLE_TIME = 120
  ANGULAR_SPEED = 0.01 * Math::PI
  FULL_CIRCLE = 2 * Math::PI
  GLOW_ANGLE = 0.16667 * Math::PI
  GLOW_RADIUS = 100
  GLOW_COLOR = Utils.with_alpha(Color::GOLD, 180)

  OBJS = %i[wall ledge water].freeze

  attr_reader :dead

  def initialize(word, x, y)
    @word = word
    @type = OBJS.include?(word) ? :obj : :prop
    @w = Text.measure(word.to_s, FONT_SIZE) + 20
    @h = FONT_SIZE + 6
    @x = x - @w / 2
    @y = y - @h / 2
    @c_x = x
    @c_y = y
    @bounds = Rectangle.new(@x, @y, @w, @h)

    @timer = 0
    @glow_angle = 0
  end

  def update(man)
    @timer += 1
    @timer = 0 if @timer == CYCLE_TIME

    @glow_angle += ANGULAR_SPEED
    @glow_angle -= FULL_CIRCLE if @glow_angle >= FULL_CIRCLE

    return unless man.bounds.intersect?(@bounds)

    man.add_word(@word, @type)
    @dead = true
  end

  def draw
    d_y = Utils.alternating_rate(@timer, CYCLE_TIME) * -10

    r = GLOW_RADIUS + Utils.alternating_rate(@timer, CYCLE_TIME) * 30
    (0..5).each do |i|
      a1 = @glow_angle + GLOW_ANGLE * 2 * i
      a2 = @glow_angle + GLOW_ANGLE * (2 * i + 1)
      x1 = @c_x + r * Math.cos(a1)
      y1 = @c_y + r * Math.sin(a1) + d_y
      x2 = @c_x + r * Math.cos(a2)
      y2 = @c_y + r * Math.sin(a2) + d_y
      G.window.draw_triangle(@c_x, @c_y + d_y, GLOW_COLOR, x1, y1, Color::GOLD_TRANSP, x2, y2, Color::GOLD_TRANSP, 0)
    end

    case @word
    when :wall
      G.window.draw_rect(@x, @y + d_y, @w, @h, Color::GRAY)
    end

    Text.draw(@word.to_s, @x + 10, @y + 3 + d_y, FONT_SIZE, false, Color::BLACK, 4)
  end
end
