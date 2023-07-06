module UI
  class MiscInfoView
    attr_accessor :x, :y, :w, :h

    attr_rect

    def initialize(game_boy, x:, y:, w:, h:)
      @game_boy = game_boy
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      x = @x + 10
      y = top - 10
      gtk_outputs.primitives << { x: x, y: y, text: "Cycles: #{@game_boy.cpu.cycles}" }.label!
    end
  end
end
