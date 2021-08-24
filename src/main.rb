require 'minigl'
require_relative 'screen'
require_relative 'man'

include MiniGL

class Window < GameWindow
  def initialize
    super(800, 600, false)

    @screen = Screen.new
    @man = Man.new(0, 0)
  end

  def update
    KB.update
    @man.update(@screen)
  end

  def draw
    clear Color::WHITE
    @screen.draw
    @man.draw
  end
end

Window.new.show
