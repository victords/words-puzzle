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

  ANIM_IDLE_CYCLE = 90

  include Movement

  attr_reader :x, :y, :w, :h
  attr_writer :on_leave, :on_mana_change

  def initialize
    @w = WIDTH
    @h = HEIGHT
    @speed = Vector.new
    @stored_forces = Vector.new
    @max_speed = Vector.new(MAX_H_SPEED, MAX_V_SPEED)
    @mass = 1
    @mana = 3

    @anim_frame = 0
  end

  def set_position(x, y = nil)
    if x.is_a?(Vector)
      @x = x.x
      @y = x.y
    else
      @x = x
      @y = y
    end
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
      speed.y = -JUMP_FORCE
    elsif stuck
      @speed.y = 0 if @speed.y > 0
    end

    if inside_liquid
      prev_g = G.gravity
      G.gravity *= Physics::LIQUID_GRAVITY_SCALE
      @max_speed *= Physics::LIQUID_GRAVITY_SCALE
      speed *= Physics::LIQUID_GRAVITY_SCALE
    end
    move(speed, screen.get_obstacles, [])
    if inside_liquid
      G.gravity = prev_g
      @max_speed = Vector.new(MAX_H_SPEED, MAX_V_SPEED)
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

    if @x < -@w / 2
      @on_leave&.call(:left)
    elsif @x + @w > G.window.width + @w / 2
      @on_leave&.call(:right)
    end

    @on_mana_change.call(@mana -= 1) if KB.key_pressed?(Gosu::KB_Z)

    # animation
    rate = (@anim_frame >= ANIM_IDLE_CYCLE / 2 ? ANIM_IDLE_CYCLE - @anim_frame : @anim_frame).to_f / ANIM_IDLE_CYCLE
    @head_top = rate * 4
    @vest_offset = rate * 3

    @anim_frame += 1
    @anim_frame = 0 if @anim_frame == ANIM_IDLE_CYCLE
  end

  def draw
    G.window.draw_triangle(@x + @w / 2, @y + @head_top + 5, Color::DARK_BLUE,
                           @x - @vest_offset, @y + @h, Color::DARK_BLUE,
                           @x + @w + @vest_offset, @y + @h, Color::DARK_BLUE, 0)
    G.window.draw_circle(@x + 4, @y + @head_top, 24, Color::BEIGE)
    G.window.draw_rect(@x + @w / 2 - 7, @y + @head_top + 6, 4, 8, Color::BLACK)
    G.window.draw_rect(@x + @w / 2 + 3, @y + @head_top + 6, 4, 8, Color::BLACK)
    G.window.draw_triangle(@x + @w / 2, @y + @head_top - 20, Color::DARK_BLUE,
                           @x + @w / 2 - 12, @y + @head_top + 3, Color::DARK_BLUE,
                           @x + @w / 2 + 12, @y + @head_top + 3, Color::DARK_BLUE, 0)
    G.window.draw_circle(@x - 5 - @vest_offset, @y + @head_top / 2 + 35, 12, Color::BEIGE)
    G.window.draw_circle(@x + @w - 7 + @vest_offset, @y + @head_top / 2 + 35, 12, Color::BEIGE)
  end
end
