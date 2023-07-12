class VRAM
  attr_reader :palettes

  def initialize
    @values = []
    @palettes = {}
    @tiles = []
    @dirty_tiles = {}
    @tilemaps = [Tilemap.new, Tilemap.new]
  end

  def clear
    0x8000.upto(0x9FFF) do |address|
      @values[address - 0x8000] = 0
    end
    @tiles = 384.times.map { Tile.new }
    (32 * 32).times do |i|
      @tilemaps[0][i] = 0
      @tilemaps[1][i] = 0
    end
  end

  def [](address)
    @values[address - 0x8000]
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
    when 0x8000..0x97FF
      tile_index = (address - 0x8000).idiv 16
      @dirty_tiles[tile_index] = true
    when 0x9800..0x9BFF
      @tilemaps[0][(address - 0x9800)] = value
    when 0x9C00..0x9FFF
      @tilemaps[1][(address - 0x9C00)] = value
    else
      raise 'Illegal VRAM address: %04X' % address
    end
    @values[address - 0x8000] = value
  end

  def tile(tile_index)
    @tiles[tile_index] ||= Tile.new
  end

  def tilemap(tilemap_index)
    @tilemaps[tilemap_index]
  end

  def update_dirty_tiles
    updated_tiles = @dirty_tiles.keys
    @dirty_tiles.clear

    updated_tiles.each do |tile_index|
      pixels = Array.new(64) { 0 }

      tile_address = (tile_index * 16)
      8.times do |y_from_top|
        low_byte = @values[tile_address + (y_from_top * 2)]
        high_byte = @values[tile_address + (y_from_top * 2) + 1]
        next unless low_byte && high_byte

        8.times do |x|
          bit_index = 7 - x
          low_bit = (low_byte >> bit_index) & 0b1
          high_bit = (high_byte >> bit_index) & 0b1
          pixels[(y_from_top * 8 + x)] = (high_bit << 1) | low_bit
        end
      end

      tile(tile_index).pixels = pixels
    end

    updated_tiles
  end

  class Tile
    attr_accessor :pixels

    def initialize
      @pixels = Array.new(64) { 0 }
    end

    def pixel_primitives(palette)
      result = []
      @pixels.each_with_index do |pixel, index|
        color = palette[pixel]
        next unless color

        result << {
          x: index % 8, y: 7 - index.idiv(8), w: 1, h: 1,
          path: :pixel
        }.sprite!(color)
      end

      result
    end
  end

  class Tilemap
    def initialize
      @tile_indexes = Array.new(32 * 32)
    end

    def [](index)
      @tile_indexes[index]
    end

    def []=(index, value)
      @tile_indexes[index] = value
    end

    def tile_primitives
      @tile_indexes.map_with_index { |tile_index, index|
        {
          x: (index % 32) * 8, y: (31 - index.idiv(32)) * 8, w: 8, h: 8,
          path: "tile#{tile_index}"
        }.sprite!
      }
    end
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
