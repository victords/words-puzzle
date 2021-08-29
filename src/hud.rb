class Hud
  def initialize(max_mana)
    @mana = @max_mana = max_mana
  end

  def update_mana(amount)
    @mana = amount
  end

  def update_max_mana(amount)
    @max_mana = amount
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
  end
end
