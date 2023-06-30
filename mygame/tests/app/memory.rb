def test_memory_loads_boot_rom_at_0x0000_if_specified(_args, assert)
  memory = Memory.new rom: "\x03\x02\x01", boot_rom: "\x01\x02\x03"

  assert.equal! memory[0x0000..0x0002], [0x01, 0x02, 0x03]
end
