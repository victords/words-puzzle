include MiniGL

require_relative 'constants'

class Man
  WIDTH = 32
  HEIGHT = 64
  SPEED = 5

  include Movement

  attr_reader :x, :y, :w, :h

  def initialize(x, y)
    @x = x
    @y = y
    @w = WIDTH
    @h = HEIGHT
    @speed = Vector.new
    @stored_forces = Vector.new
    @max_speed = Vector.new(SPEED, 25)
    @mass = 1
  end

  def update(screen)
    speed = Vector.new
    if KB.key_down?(Gosu::KB_RIGHT)
      speed.x += SPEED
    elsif KB.key_down?(Gosu::KB_LEFT)
      speed.x -= SPEED
    else
      speed.x = -@speed.x
    end
    move(speed, screen.get_obstacles, [])
  end

  def draw
    G.window.draw_triangle(@x + @w / 2, @y, Color::BLACK_A,
                           @x, @y + @h, Color::BLACK_A,
                           @x + @w, @y + @h, Color::BLACK_A, 0)
  end
end
