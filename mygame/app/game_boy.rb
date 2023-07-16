class GameBoy
  attr_reader :rom, :boot_rom, :registers, :memory, :cpu, :io, :vram, :clock, :lcd

  def initialize(rom, boot_rom: nil)
    @rom = rom
    @boot_rom = boot_rom
    @registers = Registers.new
    @memory = Memory.new
    @cpu = CPU.new registers: @registers, memory: @memory
    @io = GameBoyIO.new
    @vram = VRAM.new
    @lcd = LCD.new
    @clock = Clock.new cpu: @cpu, lcd: @lcd

    @memory.load_rom $gtk.read_file("roms/#{@rom}")
    @memory.load_boot_rom $gtk.read_file(@boot_rom) if @boot_rom
    @memory.connect_io @io
    @memory.connect_vram @vram
    @memory.connect_lcd @lcd

    @clock.schedule_next_cpu_operation
    @clock.schedule_next_lcd_scanline

    setup_memory unless boot_rom
  end

  private

  def setup_memory
    @registers.pc = 0x0100
  end
end
