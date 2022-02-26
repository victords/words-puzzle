include MiniGL

require_relative 'constants'
require_relative 'particles'
require_relative 'utils'

class Man < GameObject
  MOVE_FORCE = 0.5
  JUMP_FORCE = 15
  MAX_H_SPEED = 5
  MAX_V_SPEED = 25
  BRAKE_RATE = 0.15

  ANIM_IDLE_CYCLE = 90
  ANIM_WALK_CYCLE = 40
  ANIM_SPELL_CYCLE = 60

  attr_writer :on_leave,
              :on_start_spell,
              :on_update_spell,
              :on_cancel_spell,
              :on_cast_spell,
              :on_mana_change

  def initialize
    super(0, 0, Physics::MAN_WIDTH, Physics::MAN_HEIGHT, :sprite_man, Vector.new(-26, -32), 4, 3)
    @max_speed = Vector.new(MAX_H_SPEED, MAX_V_SPEED)

    @mana = 0
    @max_mana = Game::INITIAL_MAX_MANA
    @spell_objs = []
    @spell_props = [:sticky, :bouncy, :semisolid, :liquid]

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
    if @speed.x > G.min_speed.x
      if @speed.y < 0
        set_animation(8) if @img_index != 8 && @img_index != 9
        animate_once([8, 9], 10)
      elsif @speed.y > 0
        set_animation(8)
      else
        set_animation(2) if @img_index != 2 && @img_index != 3
        animate([2, 3], 12)
      end
    elsif @speed.x < -G.min_speed.x
      if @speed.y < 0
        set_animation(10) if @img_index != 10 && @img_index != 11
        animate_once([10, 11], 10)
      elsif @speed.y > 0
        set_animation(10)
      else
        set_animation(4) if @img_index != 4 && @img_index != 5
        animate([4, 5], 12)
      end
    elsif @speed.y < 0
      set_animation(6) if @img_index != 6 && @img_index != 7
      animate_once([6, 7], 10)
    elsif @speed.y > 0
      set_animation(6)
    else
      set_animation(0) if @img_index != 0 && @img_index != 1
      animate([0, 1], 24)
    end

    if @spell
      @spell_particles.move(@x + @w + @wand_offset[1].x, @y + @wand_offset[1].y)
    end

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

  def draw
    super(nil, 2, 2)

    @spell_particles.draw
    @mana_particles.draw
  end
end
