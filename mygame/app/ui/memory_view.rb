module UI
  class MemoryView
    LINE_SPACING = 28
    BYTE_SPACING = 35

    attr_accessor :bytes, :x, :y, :w, :h, :highlights
    attr_reader :offset

    attr_rect

    def initialize(bytes, x:, y:, w:, h:)
      @bytes = bytes
      @x = x
      @y = y
      @w = w
      @h = h
      @offset = 0
      @highlights = []
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      render_highlights(gtk_outputs)
      render_bytes(gtk_outputs)
    end

    def offset=(value)
      @offset = value.clamp(0, @bytes.length - 1)
      @offset &= 0xFFF0 # Align to 16-byte boundary
    end

    def address_visible?(address)
      address >= @offset && address <= maximum_visible_address
    end

    private

    def render_bytes(gtk_outputs)
      y = top - vertical_padding
      address = @offset
      while y > @y + vertical_padding
        16.times do |i|
          gtk_outputs.primitives << {
            x: @x + 80 + (i * BYTE_SPACING), y: y, text: '%02X' % @bytes[address + i],
          }.label!
        end
        gtk_outputs.primitives << {
          x: x + 10, y: y, text: '%04X' % (address & 0xFFF0),
          r: 100, g: 100, b: 100
        }.label!
        y -= LINE_SPACING
        address += 16
        break if address >= @bytes.length
      end
    end

    def render_highlights(gtk_outputs)
      @highlights.each do |highlight|
        addresses = highlight[:address].is_a?(Range) ? highlight[:address].to_a : [highlight[:address]]
        addresses.each do |address|
          next unless address >= @offset && address <= maximum_visible_address

          extra_size = highlight[:size] ? (highlight[:size] - 1) * 3 : 0

          x = @x + 75 + (address & 0x000F) * BYTE_SPACING
          y = top - vertical_padding - ((address - @offset).idiv(16) * LINE_SPACING) - 20

          gtk_outputs.primitives << {
            x: x - extra_size, y: y - extra_size,
            w: 30 + (extra_size * 2), h: 20 + (extra_size * 2), path: :pixel
          }.solid!(highlight[:color])
        end
      end
    end

    def maximum_visible_address
      visible_lines = (@h - vertical_padding * 2).idiv LINE_SPACING
      @offset + (visible_lines * 16) - 1
    end

    def vertical_padding
      15
    end
  end
end
