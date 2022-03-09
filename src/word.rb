require_relative 'constants'
require_relative 'utils'

class Word < MiniGL::GameObject
  OBJS = %i[wall ledge water].freeze
  CYCLE_STEP = Math::PI * 0.025

  attr_reader :dead

  def initialize(word, x, y)
    super(x - 40, y - 4, 120, 48, "word_#{word}", Vector.new(-20, -16), 1, 3)
    @word = word
    @type = OBJS.include?(word) ? :obj : :prop
    @start_y = @y
    @cycle = 0
  end

  def update(man)
    animate([0, 1, 2, 1], 8)

    @cycle += CYCLE_STEP
    @cycle = 0 if @cycle >= 2 * Math::PI
    @y = @start_y + 4 * Math.sin(@cycle)

    return unless man.bounds.intersect?(bounds)

    man.add_word(@word, @type)
    @dead = true
  end

  def draw
    super(nil, Graphics::SCALE, Graphics::SCALE)
    Graphics::text_helper.write_line(@word.to_s.upcase, @x + @w / 2, @y + 2, :center, 0xffffff, 255, :border, 0, 2, 255, 0, 4, 4)
  end
end
