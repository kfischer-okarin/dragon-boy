require 'tests/test_helper.rb'

def test_vram_remembers_set_values(_args, assert)
  vram = VRAM.new

  (0x8000..0x9FFF).each do |address|
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
