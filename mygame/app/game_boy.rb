class GameBoy
  attr_reader :registers, :memory

  def initialize(rom)
    @registers = Registers.new
    @memory = Program.new $gtk.read_file("roms/#{rom}")
    @rom = rom
  end
end
