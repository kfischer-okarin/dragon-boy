class GameBoy
  attr_reader :registers, :memory

  def initialize(rom, boot_rom: nil)
    @rom = rom
    @boot_rom = boot_rom
    @registers = Registers.new
    @memory = Memory.new(
      rom: $gtk.read_file("roms/#{@rom}"),
      boot_rom: @boot_rom ? $gtk.read_file(@boot_rom) : nil
    )

    setup_memory unless boot_rom
  end

  private

  def setup_memory
    @registers.pc = 0x0100
  end
end
