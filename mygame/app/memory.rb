class Memory
  def initialize(rom:, boot_rom:)
    @content = boot_rom.bytes
  end

  def [](address)
    @content[address]
  end
end
