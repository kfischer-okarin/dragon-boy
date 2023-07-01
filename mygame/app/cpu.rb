class CPU
  attr_reader :cycles

  def initialize(registers:, memory:)
    @registers = registers
    @memory = memory
    @cycles = 0
  end

  def execute(operation)
    @registers.pc += operation[:length]
    cycles_taken = send("execute_#{operation[:type]}", operation)
    @cycles += cycles_taken
  end

  private

  def execute_LD(operation)
    arguments = operation[:arguments]
    @registers.send "#{arguments[0].downcase}=", arguments[1]
    operation[:cycles]
  end
end
