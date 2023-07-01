class Memory
  def initialize
    @rom = nil
    @boot_rom = nil
    @content = Array.new(length)
  end

  def load_rom(rom)
    @rom = rom.bytes
    @content = @rom.dup
  end

  def load_boot_rom(boot_rom)
    @boot_rom = boot_rom.bytes
    @content[0x0000..0x00FF] = @boot_rom
  end

  def [](address)
    @content[address]
  end

  def length
    65_536
  end
end
