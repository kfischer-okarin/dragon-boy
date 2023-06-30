class Memory
  def initialize(rom:, boot_rom: nil)
    @rom = rom.bytes
    @boot_rom = boot_rom&.bytes

    @content = @rom.dup
    @content[0x0000..0x00FF] = @boot_rom if @boot_rom
  end

  def [](address)
    @content[address]
  end

  def length
    65_536
  end
end
