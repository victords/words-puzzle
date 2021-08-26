include MiniGL

require_relative 'constants'

class Man
  WIDTH = 32
  HEIGHT = 64
  MOVE_FORCE = 0.5
  JUMP_FORCE = 20
  MAX_H_SPEED = 5
  MAX_V_SPEED = 25
  BRAKE_RATE = 0.15

  include Movement

  attr_reader :x, :y, :w, :h

  def initialize(x, y)
    @x = x
    @y = y
    @w = WIDTH
    @h = HEIGHT
    @speed = Vector.new
    @stored_forces = Vector.new
    @max_speed = Vector.new(MAX_H_SPEED, MAX_V_SPEED)
    @mass = 1
  end

  def update(screen)
    speed = Vector.new
    if KB.key_down?(Gosu::KB_RIGHT)
      speed.x += MOVE_FORCE
    elsif KB.key_down?(Gosu::KB_LEFT)
      speed.x -= MOVE_FORCE
    else
      speed.x = -BRAKE_RATE * @speed.x
    end

    stuck = (@left || @right)&.sticky?
    inside_liquid = screen.inside_liquid?(self)

    if (stuck || inside_liquid || @bottom) && KB.key_pressed?(Gosu::KB_SPACE)
      speed.y = -JUMP_FORCE * (inside_liquid ? Physics::LIQUID_GRAVITY_SCALE : 1)
    elsif stuck
      @speed.y = 0 if @speed.y > 0
    end

    if inside_liquid
      prev_g = G.gravity.y
      G.gravity.y *= Physics::LIQUID_GRAVITY_SCALE
      @max_speed.y *= Physics::LIQUID_GRAVITY_SCALE
    end
    move(speed, screen.get_obstacles, [])
    if inside_liquid
      G.gravity.y = prev_g
      @max_speed.y = MAX_V_SPEED
    end

    if @left&.bouncy? || @right&.bouncy?
      @stored_forces.x = @left ? MAX_H_SPEED : -MAX_H_SPEED
    end
    if @top&.bouncy? && @speed.y == 0
      @stored_forces.y = -@prev_speed.y
    end
    if @bottom&.bouncy? && @speed.y == 0
      @stored_forces.y = -JUMP_FORCE
    end
  end

  def draw
    G.window.draw_triangle(@x + @w / 2, @y + 12, Color::BLACK_A,
                           @x, @y + @h, Color::BLACK_A,
                           @x + @w, @y + @h, Color::BLACK_A, 0)
    G.window.draw_circle(@x + 4, @y, 24, Color::BLACK_A)
  end
end
