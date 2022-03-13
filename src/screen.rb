require_relative 'objs/ledge'
require_relative 'objs/slime'
require_relative 'objs/spring'
require_relative 'objs/wall'
require_relative 'objs/water'
require_relative 'mana'

include MiniGL

class Screen
  def initialize(num)
    @objects = []
    @pickups = []
    @entrances = {}
    @exits = {}
    File.open("#{Res.prefix}screen/#{num}") do |f|
      f.each_line do |l|
        data = l.chomp.split(':')
        case data[0]
        when 'bg'
          @bg = Res.img("bg_#{data[1]}")
        when 'entr'
          pos = data[1].split(',').map(&:to_i)
          @entrances[data[2]&.to_sym || :default] = Vector.new(pos[0], pos[1])
        when 'exit'
          @exits[data[1].to_sym] = data[2].to_i
        when 'mana'
          @pickups << Mana.new(*data[1].split(',').map { |v| v.to_i * Graphics::TILE_SIZE })
        when 'word'
          pos = data[2].split(',').map { |v| v.to_i * Graphics::TILE_SIZE }
          @pickups << Word.new(data[1].to_sym, pos[0], pos[1])
        else
          bounds = data[1].split(',').map { |v| v.to_i * Graphics::TILE_SIZE }
          @objects << Object.const_get(data[0].capitalize).new(bounds[0], bounds[1], bounds[2], bounds[3])
        end
      end
    end

    unless @exits.has_key?(:left)
      @objects << Obj.new(-1, 0, 1, Graphics::SCREEN_HEIGHT, [:solid])
    end
    unless @exits.has_key?(:right)
      @objects << Obj.new(Graphics::SCREEN_WIDTH, 0, 1, Graphics::SCREEN_HEIGHT, [:solid])
    end

    @particles = []
  end

  def entrance(id)
    @entrances[id] || @entrances[:default]
  end

  def exit(dir)
    @exits[dir]
  end

  def reset
    @objects.each(&:reset)
  end

  def get_obstacles
    @objects.select { |o| o.solid? || o.semisolid? }
  end

  def inside_liquid?(obj)
    @objects.any? { |o| o != obj && o.liquid? && o.bounds.intersect?(obj.bounds) }
  end

  def highlight(obj_type)
    @objects.each { |o| o.highlight = o.type == obj_type }
  end

  def apply(obj_type, prop)
    @objects.select { |o| o.type == obj_type }.each { |o| o.add_prop(prop) }
  end

  def update(man)
    @objects.each { |o| o.update(man) }
    @pickups.reverse_each do |p|
      p.update(man)
      next unless p.dead

      case p
      when Mana
        @particles << {
          particles: Particles.new(:glow, p.x + p.w / 2, p.y + p.h / 2, Color::LIME, 100, 1, 0).start,
          mana: man.mana,
          update: lambda do |obj|
            pt = obj[:particles]
            d_x = 52 + (obj[:mana] - 1) * 82 - pt.x
            d_y = 30 - pt.y
            if d_x.abs <= 0.1 && d_y.abs <= 0.1
              pt.stop
              return false
            else
              pt.move(pt.x + d_x * 0.05, pt.y + d_y * 0.05)
            end
            true
          end
        }
      when Word
        @particles << (pt = {
          particles: Particles.new(:glow, p.x, p.y, Color::WHITE, 10, 1, 0, Vector.new(p.w, p.h)).start,
          timer: 60,
          update: lambda do |obj|
            if obj[:timer] <= 1
              obj[:particles].stop
              return false
            end

            obj[:timer] -= 1
          end
        })
        30.times { pt[:particles].update }
      end
      @pickups.delete(p)
    end

    @particles.reverse_each do |p|
      p[:particles].update
      next if p[:update].call(p)

      @particles.delete(p) if p[:particles].element_count.zero?
    end
  end

  def draw
    @bg.draw(0, 0, 0, Graphics::SCALE, Graphics::SCALE)
    @objects.each(&:draw)
    @pickups.each(&:draw)
    @particles.each { |p| p[:particles].draw }
  end
end
