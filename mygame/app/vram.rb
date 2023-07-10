class VRAM
  attr_reader :palettes

  def initialize
    @values = {}
    @palettes = {}
  end

  def [](address)
    @values[address]
  end

  def []=(address, value)
    case address
    when 0xFF47
      @palettes[:bg] = [
        palette_color(value & 0b00000011),
        palette_color((value & 0b00001100) >> 2),
        palette_color((value & 0b00110000) >> 4),
        palette_color((value & 0b11000000) >> 6)
      ]
    end
    @values[address] = value
  end

  private

  def palette_color(value)
    case value
    when 0b00
      :white
    when 0b01
      :light_gray
    when 0b10
      :dark_gray
    when 0b11
      :black
    end
  end
end
