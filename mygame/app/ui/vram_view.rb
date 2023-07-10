module UI
  class VRAMView
    attr_accessor :vram, :x, :y, :w, :h

    attr_rect

    def initialize(vram, x:, y:, w:, h:)
      @vram = vram
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
      render_bg_palette(gtk_outputs, left_column_x, y)
    end

    def vertical_padding
      15
    end

    # https://lospec.com/palette-list/kirokaze-gameboy
    PALETTE = {
      white: { r: 0xe2, g: 0xf3, b: 0xe4 },
      light_gray: { r: 0x94, g: 0xe3, b: 0x44 },
      dark_gray: { r: 0x46, g: 0x87, b: 0x8f },
      black: { r: 0x33, g: 0x2c, b: 0x50 }
    }

    private

    def render_bg_palette(gtk_outputs, x, y)
      gtk_outputs.primitives << { x: x, y: y, text: 'BG Palette:' }.label!

      return unless @vram.palettes[:bg]

      @vram.palettes[:bg].each_with_index do |color, index|
        gtk_outputs.primitives << {
          x: x + 100 + index * 20, y: y - 20, w: 20, h: 20, path: :pixel
        }.sprite!(PALETTE[color])
      end
    end
  end
end
