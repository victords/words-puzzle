include MiniGL

require_relative 'constants'

class Man
  MOVE_FORCE = 0.5
  JUMP_FORCE = 15
  MAX_H_SPEED = 5
  MAX_V_SPEED = 25
  BRAKE_RATE = 0.15

  ANIM_IDLE_CYCLE = 90
  ANIM_WALK_CYCLE = 40

  include Movement

  attr_reader :x, :y, :w, :h
  attr_writer :on_leave, :on_start_spell, :on_mana_change

  def initialize
    @w = Physics::MAN_WIDTH
    @h = Physics::MAN_HEIGHT
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

    @on_start_spell.call(@x, @y) if KB.key_pressed?(Gosu::KB_Z)

    # ========================== animation ===========================
    walking = @speed.x.abs > G.min_speed.x
    cycle_time = walking ? ANIM_WALK_CYCLE : ANIM_IDLE_CYCLE
    @anim_frame = 0 if @anim_frame > cycle_time
    rate = (@anim_frame >= cycle_time / 2 ? cycle_time - @anim_frame : @anim_frame).to_f / cycle_time

    if walking
      @head_offset = rate * 4
      @vest_offset = rate * 5
      @eye_offset = @speed.x < 0 ? 8 : 2
    else
      @head_offset = rate * 4
      @vest_offset = rate * 3
      @eye_offset = 5
    end

    @anim_frame += 1
    @anim_frame = 0 if @anim_frame == cycle_time
  end

  def draw
    G.window.draw_triangle(@x + @w / 2, @y + @head_offset + 5, Color::DARK_BLUE,
                           @x - @vest_offset, @y + @h, Color::DARK_BLUE,
                           @x + @w + @vest_offset, @y + @h, Color::DARK_BLUE, 0)
    G.window.draw_circle(@x + 4, @y + @head_offset, 24, Color::BEIGE)
    G.window.draw_rect(@x + @w / 2 - @eye_offset - 2, @y + @head_offset + 6, 4, 8, Color::BLACK)
    G.window.draw_rect(@x + @w / 2 - @eye_offset + 8, @y + @head_offset + 6, 4, 8, Color::BLACK)
    G.window.draw_triangle(@x + @w / 2, @y + @head_offset - 20, Color::DARK_BLUE,
                           @x + @w / 2 - 12, @y + @head_offset + 3, Color::DARK_BLUE,
                           @x + @w / 2 + 12, @y + @head_offset + 3, Color::DARK_BLUE, 0)
    G.window.draw_circle(@x - 5 - @vest_offset, @y + @head_offset / 2 + 35, 12, Color::BEIGE)
    G.window.draw_circle(@x + @w - 7 + @vest_offset, @y + @head_offset / 2 + 35, 12, Color::BEIGE)

    # wand
    e1 = Vector.new(@x + @w + @vest_offset, @y + @head_offset / 2 + 48)
    e2 = Vector.new(@x + @w + 32, @y + @head_offset / 2 + 12)
    v = e2 - e1
    d = Math.sqrt(v.x * v.x + v.y * v.y)
    o = v.rotate(Math::PI * 0.5) / d
    p1 = e1 + o
    p2 = e1 - o
    p3 = e2 + o
    p4 = e2 - o
    G.window.draw_quad(p1.x, p1.y, Color::BLACK,
                       p2.x, p2.y, Color::BLACK,
                       p3.x, p3.y, Color::BLACK,
                       p4.x, p4.y, Color::BLACK, 0)
  end
end
