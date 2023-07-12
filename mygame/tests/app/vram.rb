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
       0,    0,    0,    0,    0,    0,    0,    0,
    0b00, 0b10, 0b11, 0b11, 0b11, 0b11, 0b10, 0b00,
       0,    0,    0,    0,    0,    0,    0,    0,
       0,    0,    0,    0,    0,    0,    0,    0,
       0,    0,    0,    0,    0,    0,    0,    0,
       0,    0,    0,    0,    0,    0,    0,    0,
       0,    0,    0,    0,    0,    0,    0,    0,
       0,    0,    0,    0,    0,    0,    0,    0
  ]
end

def test_vram_tile_pixel_primitives(_args, assert)
  vram = VRAM.new
  tile = vram.tile(22)
  tile.pixels = [
    0, 0, 0, 3, 0, 0, 0, 0,
    0, 0, 3, 2, 3, 0, 0, 0,
    0, 0, 0, 1, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0
  ]

  colors = [
    nil,
    { r: 0, g: 0, b: 0 },
    { r: 255, g: 0, b: 0 },
    { r: 0, g: 255, b: 0 }
  ]
  assert.equal! tile.pixel_primitives(colors), [
    { x: 3, y: 7, w: 1, h: 1, path: :pixel, r: 0, g: 255, b: 0 }.sprite!,
    { x: 2, y: 6, w: 1, h: 1, path: :pixel, r: 0, g: 255, b: 0 }.sprite!,
    { x: 3, y: 6, w: 1, h: 1, path: :pixel, r: 255, g: 0, b: 0 }.sprite!,
    { x: 4, y: 6, w: 1, h: 1, path: :pixel, r: 0, g: 255, b: 0 }.sprite!,
    { x: 3, y: 5, w: 1, h: 1, path: :pixel, r: 0, g: 0, b: 0 }.sprite!
  ]
end

def test_vram_tilemap0(_args, assert)
  vram = VRAM.new
  vram.clear

  vram[0x9910] = 22

  expected_tile_indexes = [0] * 32 * 32
  expected_tile_indexes[0x0110] = 22

  assert.equal! vram.tilemap(0).tile_indexes, expected_tile_indexes
end

def test_vram_tilemap1(_args, assert)
  vram = VRAM.new
  vram.clear

  vram[0x9D10] = 22

  expected_tile_indexes = [0] * 32 * 32
  expected_tile_indexes[0x0110] = 22

  assert.equal! vram.tilemap(1).tile_indexes, expected_tile_indexes
end
