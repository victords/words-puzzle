require_relative 'obj'

include MiniGL

class Screen
  def initialize(num)
    @objects = []
    File.open("#{Res.prefix}/screen/#{num}.txt") do |f|
      f.each_line do |l|
        data = l.chomp.split(':')
        bounds = data[1].split(',').map(&:to_i)
        @objects << Obj.new(data[0].to_sym, bounds[0], bounds[1], bounds[2], bounds[3],
                            data[2]&.split(',')&.map(&:to_sym))
      end
    end
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
