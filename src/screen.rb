require_relative 'obj'

include MiniGL

class Screen
  def initialize(num)
    @objects = []
    @entrances = {}
    @exits = {}
    File.open("#{Res.prefix}screen/#{num}") do |f|
      f.each_line do |l|
        data = l.chomp.split(':')
        if data[0] == 'entr'
          pos = data[1].split(',').map(&:to_i)
          @entrances[data[2]&.to_sym || :default] = Vector.new(pos[0], pos[1])
        elsif data[0] == 'exit'
          @exits[data[1].to_sym] = data[2].to_i
        else
          bounds = data[1].split(',').map(&:to_i)
          @objects << Obj.new(data[0].to_sym, bounds[0], bounds[1], bounds[2], bounds[3],
                              data[2]&.split(',')&.map(&:to_sym))
        end
      end
    end
  end

  def entrance(id)
    @entrances[id] || @entrances[:default]
  end

  def exit(dir)
    @exits[dir]
  end

  def reset
    # TODO
  end

  def get_obstacles
    @objects.select { |o| o.solid? || o.semisolid? }
  end

  def inside_liquid?(obj)
    @objects.any? { |o| o != obj && o.liquid? && o.bounds.intersect?(obj.bounds) }
  end

  def update
    @objects.each(&:update)
  end

  def draw
    @objects.each(&:draw)
  end
end
