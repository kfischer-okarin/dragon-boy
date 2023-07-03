class GameBoy
  attr_reader :rom, :boot_rom, :registers, :memory, :cpu, :io

  def initialize(rom, boot_rom: nil)
    @rom = rom
    @boot_rom = boot_rom
    @registers = Registers.new
    @memory = Memory.new
    @cpu = CPU.new registers: @registers, memory: @memory
    @io = GameBoyIO.new

    @memory.load_rom $gtk.read_file("roms/#{@rom}")
    @memory.load_boot_rom $gtk.read_file(@boot_rom) if @boot_rom
    @memory.connect_io @io

    setup_memory unless boot_rom
  end

  private

  def setup_memory
    @registers.pc = 0x0100
  end
end
