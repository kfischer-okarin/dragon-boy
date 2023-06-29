module UI
  class MemoryView
    attr_accessor :bytes, :x, :y, :w, :h

    attr_rect

    def initialize(bytes, x:, y:, w:, h:)
      @bytes = bytes
      @x = x
      @y = y
      @w = w
      @h = h
      @offset = 0
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      y = top - 10
      address = @offset
      byte_spacing = 35
      line_spacing = 28
      while y > @y
        16.times do |i|
          gtk_outputs.primitives << {
            x: @x + 80 + (i * byte_spacing), y: y, text: '%02X' % @bytes[address + i],
          }.label!
        end
        gtk_outputs.primitives << {
          x: x + 10, y: y, text: '%04X' % (address & 0xFFF0),
          r: 100, g: 100, b: 100
        }.label!
        y -= line_spacing
        address += 16
        break if address >= @bytes.length
      end
    end
  end
end
