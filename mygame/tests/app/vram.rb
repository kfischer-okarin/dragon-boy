require 'tests/test_helper.rb'

def test_vram_remembers_set_values(_args, assert)
  vram = VRAM.new

  0x8000.upto(0x9FFF).each do |address|
    vram[address] = 0xAA

    assert.equal! vram[address], 0xAA, "Expected #{address} to be 0xAA"
  end
end

def test_vram_cannot_write_to_unrelated_addresses(_args, assert)
  vram = VRAM.new

  assert.exception_raised! do
    vram[0x7FFF] = 0xAA
  end
end

def test_vram_palettes_bg(_args, assert)
  vram = VRAM.new

  vram[0xFF47] = 0b11010010

  assert.equal! vram.palettes[:bg], [:dark_gray, :white, :light_gray, :black]
end

def test_vram_writing_to_tile_memory_updates_tile_pixels(_args, assert)
  vram = VRAM.new
  vram.clear

  vram[0x8032] = 0b00111100
  vram[0x8033] = 0b01111110
  updated_tiles = vram.update_dirty_tiles

  assert.equal! updated_tiles, [3]
  assert.equal! vram.tile(3).pixels, [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0b00, 0b10, 0b11, 0b11, 0b11, 0b11, 0b10, 0],
    [0, 0, 0, 0, 0, 0, 0, 0]
  ]
end
