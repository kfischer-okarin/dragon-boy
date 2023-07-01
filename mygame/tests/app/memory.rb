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

def test_memory_length_is_always_64KB(_args, assert)
  memory = Memory.new
  memory.load_rom("\xAA" * 256)

  assert.equal! memory.length, 64 * 1024
end
