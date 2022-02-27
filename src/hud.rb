require_relative 'constants'
require_relative 'utils'

class Hud
  BALLOON_V_LIMIT = 200
  CYCLE_TIME = 60

  def initialize
    @max_mana = Game::INITIAL_MAX_MANA
    @mana = 0
    @timer = 0
  end

  def update_mana(amount)
    @mana_alpha = amount < @mana ? 255 : 0
    @mana_alpha_change = amount < @mana ? -10 : 10
    @mana = amount if amount > @mana
  end

  def update_max_mana(amount)
    @max_mana = amount
  end

  def start_spell(x, y, obj, prop)
    @spell = { obj: obj, prop: prop, state: :obj }
    m_w_half = Physics::MAN_WIDTH / 2
    m_h = Physics::MAN_HEIGHT
    scr_w = Graphics::SCREEN_WIDTH
    b_w = scr_w - 400
    b_offset = b_w / 4
    @balloon_arrow = [
      x + m_w_half, y < BALLOON_V_LIMIT ? y + m_h : y - 10,
      scr_w / 2 + (x > scr_w / 2 ? b_offset : -b_offset) - 20, y < BALLOON_V_LIMIT ? y + m_h + 50 : y - 60,
      scr_w / 2 + (x > scr_w / 2 ? b_offset : -b_offset) + 20, y < BALLOON_V_LIMIT ? y + m_h + 50 : y - 60,
    ]
    @balloon = [200, y < BALLOON_V_LIMIT ? y + m_h + 50 : y - 180, b_w, 120]
  end

  def update_spell(key, value)
    @spell[key] = key == :state ? value : value.to_s
  end

  def end_spell
    @spell = nil
  end

  def update
    @timer += 1
    @timer = 0 if @timer >= CYCLE_TIME

    return unless @mana_alpha_change

    @mana_alpha += @mana_alpha_change
    if @mana_alpha_change < 0 && @mana_alpha <= 0
      @mana -= 1
      @mana_alpha_change = nil
    elsif @mana_alpha_change > 0 && @mana_alpha >= 255
      @mana_alpha_change = nil
    end
  end

  def draw
    G.window.draw_rect(10, 10, 2 + @max_mana * 82, 40, Color::BLACK, nil, nil, 100)
    (0...@mana).each do |i|
      color = @mana_alpha_change && i == @mana - 1 ? Utils.with_alpha(Color::LIME, @mana_alpha) : Color::LIME
      color2 = Utils.darken(color, 0.4)
      G.window.draw_rect(12 + i * 82, 12, 80, 36, color, color2, nil, 101)
    end

    return unless @spell

    G.window.draw_triangle(@balloon_arrow[0], @balloon_arrow[1], Color::BLACK,
                           @balloon_arrow[2] - 10, @balloon_arrow[3], Color::BLACK,
                           @balloon_arrow[4] + 10, @balloon_arrow[5], Color::BLACK, 101)
    G.window.draw_triangle(@balloon_arrow[0], @balloon_arrow[1], Color::WHITE,
                           @balloon_arrow[2], @balloon_arrow[3], Color::WHITE,
                           @balloon_arrow[4], @balloon_arrow[5], Color::WHITE, 102)
    G.window.draw_rect(@balloon[0] - 5, @balloon[1] - 5, @balloon[2] + 10, @balloon[3] + 10, Color::BLACK, nil, nil, 101)
    G.window.draw_rect(@balloon[0], @balloon[1], @balloon[2], @balloon[3], Color::WHITE, nil, nil, 102)

    b_w = Graphics::SCREEN_WIDTH - 400
    Text.draw('make', @balloon[0] + b_w * 0.1, @balloon[1] + 30, 60, true, Color::BLACK, 4, 102)
    Text.draw(@spell[:obj], @balloon[0] + b_w * 0.4, @balloon[1] + 30, 60, true, Color::BLACK, 4, 102)
    Text.draw(@spell[:prop], @balloon[0] + b_w * 0.8, @balloon[1] + 30, 60, true, Color::BLACK, 4, 102)

    outline_x = @balloon[0] + b_w * (@spell[:state] == :obj ? 0.4 : 0.8) - 150
    G.window.draw_outline_rect(outline_x, @balloon[1] + 15, 300, 90, Color::GRAY, 1, 102)
    delta_y = Utils.alternating_rate(@timer, CYCLE_TIME) * 5
    G.window.draw_triangle(outline_x + 135, @balloon[1] + 25 - delta_y, Color::GOLD,
                           outline_x + 165, @balloon[1] + 25 - delta_y, Color::GOLD,
                           outline_x + 150, @balloon[1] + 5 - delta_y, Color::GOLD, 102)
    G.window.draw_triangle(outline_x + 135, @balloon[1] + 95 + delta_y, Color::GOLD,
                           outline_x + 165, @balloon[1] + 95 + delta_y, Color::GOLD,
                           outline_x + 150, @balloon[1] + 115 + delta_y, Color::GOLD, 102)
  end
end
