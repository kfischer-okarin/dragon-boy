class GameBoy
  attr_reader :registers

  def initialize(rom)
    @registers = Registers.new
    @rom = rom
  end
end
