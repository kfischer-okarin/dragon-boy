class Memory
  def initialize(rom:, boot_rom: nil)
    @content = boot_rom ? boot_rom.bytes : rom.bytes
  end

  def [](address)
    @content[address]
  end
end
