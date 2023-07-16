def test_memory_contains_ff_in_rom_memory_area_without_any_roms(_args, assert)
  memory = Memory.new

  assert.equal! memory[0x0000..0x07FF], [0xFF] * 0x0800
end

def test_memory_loads_boot_rom_at_0x0000_to_0x00FF_if_specified(_args, assert)
  memory = Memory.new

  memory.load_rom("\xAA" * 256 + "\xBB" * 256)
  memory.load_boot_rom("\x01" * 256)

  assert.equal! memory[0x00FE..0x0101], [0x01, 0x01, 0xBB, 0xBB]
end

def test_memory_loads_rom_at_0x0000_to_0x00FF_if_no_boot_rom_is_specified(_args, assert)
  memory = Memory.new

  memory.load_rom("\xAA" * 256 + "\xBB" * 256)

  assert.equal! memory[0x00FE..0x0101], [0xAA, 0xAA, 0xBB, 0xBB]
end

def test_memory_write_to_ram(_args, assert)
  memory = Memory.new

  memory[0xC000] = 0xAA

  assert.equal! memory[0xC000], 0xAA
end

def test_memory_length_is_always_64KB(_args, assert)
  memory = Memory.new
  memory.load_rom("\xAA" * 256)

  assert.equal! memory.length, 64 * 1024
end

def test_memory_to_a(_args, assert)
  memory = Memory.new
  memory.load_rom("\xAA" * 256)

  memory_array = memory.to_a

  assert.equal! memory_array.length, memory.length
  assert.equal! memory_array[0...256], ("\xAA" * 256).bytes
end

def test_memory_connect_io(_args, assert)
  memory = Memory.new
  io = { 0xFF00 => 0xAA } # Anything with #[] and #[]= will do

  memory.connect_io io

  assert.equal! memory[0xFF00], 0xAA

  memory[0xFF7F] = 0xBB

  assert.equal! io[0xFF7F], 0xBB
end

def test_memory_access_io_memory_without_connected_io(_args, assert)
  memory = Memory.new

  memory[0xFF00] = 0xBB

  assert.equal! memory[0xFF00], 0xBB
end

def test_memory_connect_vram(_args, assert)
  memory = Memory.new
  vram = { 0x8010 => 0xAA } # Anything with #[] and #[]= will do

  memory.connect_vram vram

  assert.equal! memory[0x8010], 0xAA

  memory[0x8012] = 0xBB

  assert.equal! vram[0x8012], 0xBB
end

def test_memory_access_vram_memory_without_connected_vram(_args, assert)
  memory = Memory.new

  memory[0x8005] = 0xBB

  assert.equal! memory[0x8005], 0xBB
end

def test_memory_forward_palette_setting_to_vram(_args, assert)
  memory = Memory.new
  vram = {}
  memory.connect_vram vram

  memory[0xFF47] = 0xBB

  assert.equal! vram[0xFF47], 0xBB
end

def test_memory_connect_lcd(_args, assert)
  memory = Memory.new
  lcd = { 0xFF44 => 22 } # Anything with #[] and #[]= will do

  memory.connect_lcd lcd

  assert.equal! memory[0xFF44], 22

  memory[0xFF44] = 24

  assert.equal! memory[0xFF44], 24
end

def test_memory_access_lcd_without_connected_lcd(_args, assert)
  memory = Memory.new

  memory[0xFF44] = 0xBB

  assert.equal! memory[0xFF44], 0xBB
end
