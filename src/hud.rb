require_relative 'constants'
require_relative 'utils'

class Hud
  BALLOON_X_OFFSET = -40
  BALLOON_V_LIMIT = 200
  BALLOON_WIDTH = Graphics::SCREEN_WIDTH - 400
  BALLOON_HEIGHT = 120
  CYCLE_TIME = 60

  def initialize
    @max_mana = Game::INITIAL_MAX_MANA
    @mana = 0
    @timer = 0

    @balloon = Res.imgs(:fx_balloon, 3, 3)
    @balloon_arrow = Res.img(:fx_balloonArrow)
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
    flip = y < BALLOON_V_LIMIT
    @balloon_pos = [
      # balloon coords
      [[x + BALLOON_X_OFFSET, 0].max, Graphics::SCREEN_WIDTH - BALLOON_WIDTH].min,
      flip ? y + Physics::MAN_HEIGHT + 32 : y - 152,
      # balloon arrow coords
      x + Physics::MAN_WIDTH / 2 - 16,
      flip ? y + Physics::MAN_HEIGHT + 4 : y - 36,
      # whether balloon arrow is flipped
      flip
    ]
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

    b_x = @balloon_pos[0]
    b_y = @balloon_pos[1]
    b_w = BALLOON_WIDTH
    b_h = BALLOON_HEIGHT
    sc = Graphics::SCALE
    @balloon[0].draw(b_x, b_y, 101, sc, sc)
    @balloon[1].draw(b_x + 6, b_y, 101, (b_w - 12).to_f / 3, sc)
    @balloon[2].draw(b_x + b_w - 6, b_y, 101, sc, sc)
    @balloon[3].draw(b_x, b_y + 6, 101, sc, (b_h - 12).to_f / 3)
    @balloon[4].draw(b_x + 6, b_y + 6, 101, (b_w - 12).to_f / 3, (b_h - 12).to_f / 3)
    @balloon[5].draw(b_x + b_w - 6, b_y + 6, 101, sc, (b_h - 12).to_f / 3)
    @balloon[6].draw(b_x, b_y + b_h - 6, 101, sc, sc)
    @balloon[7].draw(b_x + 6, b_y + b_h - 6, 101, (b_w - 12).to_f / 3, sc)
    @balloon[8].draw(b_x + b_w - 6, b_y + b_h - 6, 101, sc, sc)
    @balloon_arrow.draw(@balloon_pos[2], @balloon_pos[3], 101, sc, @balloon_pos[4] ? -sc : sc)

    Graphics.font.draw_text_rel('MAKE', b_x + b_w * 0.1, b_y + 27, 102, 0.5, 0, 6, 6, Color::BLACK)
    Graphics.font.draw_text_rel(@spell[:obj].upcase, b_x + b_w * 0.4, b_y + 27, 102, 0.5, 0, 6, 6, Color::BLACK)
    Graphics.font.draw_text_rel(@spell[:prop].upcase, b_x + b_w * 0.8, b_y + 27, 102, 0.5, 0, 6, 6, Color::BLACK)

    outline_x = b_x + b_w * (@spell[:state] == :obj ? 0.4 : 0.8) - 150
    G.window.draw_outline_rect(outline_x, b_y + 15, 300, 90, Color::GRAY, 1, 102)
    delta_y = Utils.alternating_rate(@timer, CYCLE_TIME) * 5
    G.window.draw_triangle(outline_x + 135, b_y + 25 - delta_y, Color::GOLD,
                           outline_x + 165, b_y + 25 - delta_y, Color::GOLD,
                           outline_x + 150, b_y + 5 - delta_y, Color::GOLD, 102)
    G.window.draw_triangle(outline_x + 135, b_y + 95 + delta_y, Color::GOLD,
                           outline_x + 165, b_y + 95 + delta_y, Color::GOLD,
                           outline_x + 150, b_y + 115 + delta_y, Color::GOLD, 102)
  end
end
