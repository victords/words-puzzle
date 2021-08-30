class Hud
  BALLOON_V_LIMIT = 200

  def initialize(max_mana)
    @mana = @max_mana = max_mana
  end

  def update_mana(amount)
    @mana = amount
  end

  def update_max_mana(amount)
    @max_mana = amount
  end

  def start_spell(x, y)
    @casting_spell = true
    m_w_half = Physics::MAN_WIDTH / 2
    m_h = Physics::MAN_HEIGHT
    scr_w = Game::SCREEN_WIDTH
    b_w = scr_w - 400
    b_offset = b_w / 4
    @balloon_arrow = [
      x + m_w_half, y < BALLOON_V_LIMIT ? y + m_h : y,
      scr_w / 2 + (x > scr_w / 2 ? b_offset : -b_offset) - 20, y < BALLOON_V_LIMIT ? y + m_h + 50 : y - 50,
      scr_w / 2 + (x > scr_w / 2 ? b_offset : -b_offset) + 20, y < BALLOON_V_LIMIT ? y + m_h + 50 : y - 50,
    ]
    @balloon = [200, y < BALLOON_V_LIMIT ? y + m_h + 50 : y - 170, b_w, 120]
  end

  def end_spell
    @casting_spell = false
  end

  def draw
    G.window.draw_quad(10, 10, Color::BLACK,
                       12 + @max_mana * 82, 10, Color::BLACK,
                       10, 50, Color::BLACK,
                       12 + @max_mana * 82, 50, Color::BLACK, 100)
    (0...@mana).each do |i|
      G.window.draw_quad(12 + i * 82, 12, Color::LIME,
                         92 + i * 82, 12, Color::LIME,
                         12 + i * 82, 48, Color::LIME,
                         92 + i * 82, 48, Color::LIME, 101)
    end

    if @casting_spell
      G.window.draw_triangle(@balloon_arrow[0], @balloon_arrow[1], Color::BLACK,
                             @balloon_arrow[2] - 10, @balloon_arrow[3], Color::BLACK,
                             @balloon_arrow[4] + 10, @balloon_arrow[5], Color::BLACK, 101)
      G.window.draw_triangle(@balloon_arrow[0], @balloon_arrow[1], Color::WHITE,
                             @balloon_arrow[2], @balloon_arrow[3], Color::WHITE,
                             @balloon_arrow[4], @balloon_arrow[5], Color::WHITE, 102)
      G.window.draw_rect(@balloon[0] - 5, @balloon[1] - 5, @balloon[2] + 10, @balloon[3] + 10, Color::BLACK, nil, 101)
      G.window.draw_rect(@balloon[0], @balloon[1], @balloon[2], @balloon[3], Color::WHITE, nil, 102)
    end
  end
end
