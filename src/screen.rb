require_relative 'obj'

include MiniGL

class Screen
  attr_reader :bg_color

  def initialize(num)
    @objects = []
    @entrances = {}
    @exits = {}
    File.open("#{Res.prefix}screen/#{num}") do |f|
      f.each_line do |l|
        data = l.chomp.split(':')
        case data[0]
        when 'entr'
          pos = data[1].split(',').map(&:to_i)
          @entrances[data[2]&.to_sym || :default] = Vector.new(pos[0], pos[1])
        when 'exit'
          @exits[data[1].to_sym] = data[2].to_i
        else
          bounds = data[1].split(',').map(&:to_i)
          @objects << Obj.new(data[0].to_sym, bounds[0], bounds[1], bounds[2], bounds[3],
                              data[2]&.split(',')&.map(&:to_sym))
        end
      end
    end

    @bg_procs = []
    File.open("#{Res.prefix}bg/#{Game::BG_MAP[num]}") do |f|
      f.each_line.with_index do |l, i|
        if i == 0
          @bg_color = l.to_i(16)
          next
        end

        data = l.chomp.split(':')
        coords = data[1].split(',').map(&:to_i)
        color = data[2].to_i(16)
        color = (255 << 24) | color if data[2].size == 6
        color2 = data[3]&.to_i(16)
        color2 = (255 << 24) | color2 if data[3]&.size == 6
        case data[0]
        when 'r'
          @bg_procs << lambda {
            G.window.draw_rect(coords[0], coords[1], coords[2], coords[3], color, color2)
          }
        when 't'
          @bg_procs << lambda {
            G.window.draw_triangle(coords[0], coords[1], color,
                                   coords[2], coords[3], color2 || color,
                                   coords[4], coords[5], color2 || color, 0)
          }
        when 'c'
          @bg_procs << lambda {
            G.window.draw_circle(coords[0], coords[1], coords[2], color, coords[3])
          }
        end
      end
    end

    unless @exits.has_key?(:left)
      @objects << Obj.new(:immutable, -1, 0, 1, 600, [:solid])
    end
    unless @exits.has_key?(:right)
      @objects << Obj.new(:immutable, 800, 0, 1, 600, [:solid])
    end
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

  def update
    @objects.each(&:update)
  end

  def draw
    @bg_procs.each(&:call)
    @objects.each(&:draw)
  end
end
