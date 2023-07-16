module UI
  class LCDView
    attr_accessor :lcd, :x, :y, :w, :h

    attr_rect

    def initialize(lcd, x:, y:, w:, h:)
      @lcd = lcd
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      y = top - vertical_padding
      left_column_x = @x + 10
      gtk_outputs.primitives << { x: left_column_x, y: y, text: 'Scanline: %3d' % @lcd.scanline }.label!
      y -= 20
      gtk_outputs.primitives << { x: left_column_x, y: y, text: "Mode: #{@lcd.mode}" }.label!
    end

    def vertical_padding
      15
    end
  end
end
