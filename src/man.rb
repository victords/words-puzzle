include MiniGL

require_relative 'constants'
require_relative 'particles'
require_relative 'utils'

class Man
  MOVE_FORCE = 0.5
  JUMP_FORCE = 15
  MAX_H_SPEED = 5
  MAX_V_SPEED = 25
  BRAKE_RATE = 0.15

  ANIM_IDLE_CYCLE = 90
  ANIM_WALK_CYCLE = 40
  ANIM_SPELL_CYCLE = 60

  include Movement

  attr_reader :x, :y, :w, :h
  attr_writer :on_leave,
              :on_start_spell,
              :on_update_spell,
              :on_cancel_spell,
              :on_cast_spell,
              :on_mana_change

  def initialize
    @w = Physics::MAN_WIDTH
    @h = Physics::MAN_HEIGHT
    @speed = Vector.new
    @stored_forces = Vector.new
    @max_speed = Vector.new(MAX_H_SPEED, MAX_V_SPEED)
    @mass = 1

    @mana = 0
    @max_mana = Game::INITIAL_MAX_MANA
    @spell_objs = []
    @spell_props = [:sticky, :bouncy, :semisolid, :liquid]

    @anim_frame = 0
    @spell_particles = Particles.new(:glow, 0, 0, Color::WHITE, 5, 1, 5, nil, 2)
    @mana_particles = Particles.new(:glow, 0, 0, Color::LIME, 100, 1, 0, nil, 4)
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
    if @spell
      if KB.key_pressed?(Gosu::KB_X)
        @spell = nil
        @on_cancel_spell.call
        @spell_particles.stop
      elsif KB.key_pressed?(Gosu::KB_Z)
        if @spell[:state] == :obj
          @spell[:state] = :prop
          @on_update_spell.call(:state, :prop)
        else
          @on_cast_spell.call(@spell[:obj], @spell[:prop])
          @on_mana_change.call(@mana -= 1)
          @spell = nil
          @spell_particles.stop
        end
      elsif KB.key_pressed?(Gosu::KB_DOWN)
        change_spell_word(-1)
      elsif KB.key_pressed?(Gosu::KB_UP)
        change_spell_word(1)
      end
      speed.x = -BRAKE_RATE * @speed.x
    else
      if KB.key_pressed?(Gosu::KB_Z) && @mana > 0 && @spell_objs.any? && @spell_props.any?
        @spell = { obj: @spell_objs[0], prop: @spell_props[0], state: :obj }
        @on_start_spell.call(@x, @y, @spell[:obj], @spell[:prop])
        @spell_particles.start
      elsif KB.key_down?(Gosu::KB_RIGHT)
        speed.x += MOVE_FORCE
      elsif KB.key_down?(Gosu::KB_LEFT)
        speed.x -= MOVE_FORCE
      else
        speed.x = -BRAKE_RATE * @speed.x
      end
    end

    stuck = (@left || @right)&.sticky?
    inside_liquid = screen.inside_liquid?(self)

    if (stuck || inside_liquid || @bottom) && KB.key_pressed?(Gosu::KB_SPACE) && @spell.nil?
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
      @on_leave.call(:left)
    elsif @x + @w > G.window.width + @w / 2
      @on_leave.call(:right)
    end

    # ========================== animation ===========================
    walking = @speed.x.abs > G.min_speed.x
    cycle_time = @spell ? ANIM_SPELL_CYCLE : walking ? ANIM_WALK_CYCLE : ANIM_IDLE_CYCLE
    @anim_frame = 0 if @anim_frame > cycle_time
    rate = Utils.alternating_rate(@anim_frame, cycle_time)

    if @spell
      @head_offset = rate * 1.5
      @vest_offset = rate
      @eye_offset = 5
      @hand_offset = [Vector.new(@vest_offset, @head_offset / 2 + 35), Vector.new(rate * 2.5, rate * 2.5 + 25)]
      @wand_offset = [Vector.new(@hand_offset[1].x + 4, @hand_offset[1].y + 8), Vector.new(rate * 20 + 30, rate * 15 + 5)]

      @spell_particles.move(@x + @w + @wand_offset[1].x, @y + @wand_offset[1].y)
    elsif walking
      @head_offset = rate * 2
      @vest_offset = rate * 2.5
      @eye_offset = @speed.x < 0 ? 8 : 2
      @hand_offset = default_hand_offsets
      @wand_offset = default_wand_offsets
    else
      @head_offset = rate * 2
      @vest_offset = rate * 1.5
      @eye_offset = 5
      @hand_offset = default_hand_offsets
      @wand_offset = default_wand_offsets
    end

    @anim_frame += 1
    @anim_frame = 0 if @anim_frame == cycle_time

    @spell_particles.update
    @mana_particles.update
    return unless @mana_particles.playing

    d_x = 52 + (@mana - 1) * 82 - @mana_particles.x
    d_y = 30 - @mana_particles.y
    if d_x.abs <= 0.1 && d_y.abs <= 0.1
      @mana_particles.stop
    else
      @mana_particles.move(@mana_particles.x + d_x * 0.05, @mana_particles.y + d_y * 0.05)
    end
  end

  def change_spell_word(delta)
    word = @spell[:state]
    list = word == :obj ? @spell_objs : @spell_props
    index = list.index(@spell[word])
    index += delta
    index = 0 if index >= list.size
    index = list.size - 1 if index < 0
    @spell[word] = list[index]
    @on_update_spell.call(word, @spell[word])
  end

  def add_mana(amount)
    return if @mana == @max_mana

    @mana += amount
    @on_mana_change.call(@mana)
    @mana_particles.move(@x + @w / 2, @y + @h / 2)
    @mana_particles.start
  end

  def add_word(word, type)
    (type == :obj ? @spell_objs : @spell_props) << word
  end

  def default_hand_offsets
    [Vector.new(@vest_offset, @head_offset / 2 + 35), Vector.new(@vest_offset, @head_offset / 2 + 35)]
  end

  def default_wand_offsets
    [Vector.new(@hand_offset[1].x, @hand_offset[1].y + 13), Vector.new(32, @head_offset / 2 + 12)]
  end

  def draw
    # body
    G.window.draw_triangle(@x + @w / 2, @y + @head_offset + 5, Color::DARK_BLUE,
                           @x - @vest_offset, @y + @h, Color::DARK_BLUE,
                           @x + @w + @vest_offset, @y + @h, Color::DARK_BLUE, 0)

    # head
    G.window.draw_circle(@x + 4, @y + @head_offset, 24, Color::BEIGE)

    # eyes
    G.window.draw_rect(@x + @w / 2 - @eye_offset - 2, @y + @head_offset + 6, 4, 8, Color::BLACK)
    G.window.draw_rect(@x + @w / 2 - @eye_offset + 8, @y + @head_offset + 6, 4, 8, Color::BLACK)

    # hat
    G.window.draw_triangle(@x + @w / 2, @y + @head_offset - 20, Color::DARK_BLUE,
                           @x + @w / 2 - 12, @y + @head_offset + 3, Color::DARK_BLUE,
                           @x + @w / 2 + 12, @y + @head_offset + 3, Color::DARK_BLUE, 0)

    # hands
    G.window.draw_circle(@x - 5 - @hand_offset[0].x, @y + @hand_offset[0].y, 12, Color::BEIGE)
    G.window.draw_circle(@x + @w - 7 + @hand_offset[1].x, @y + @hand_offset[1].y, 12, Color::BEIGE)

    # wand
    e1 = Vector.new(@x + @w + @wand_offset[0].x, @y + @wand_offset[0].y)
    e2 = Vector.new(@x + @w + @wand_offset[1].x, @y + @wand_offset[1].y)
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

    @spell_particles.draw
    @mana_particles.draw
  end
end
