class CPU
  attr_reader :cycles

  CYCLES_PER_SECOND = 4_194_304

  def initialize(registers:, memory:)
    @registers = registers
    @memory = memory
    @cycles = 0
  end

  def execute_next_operation
    execute Operation.parse(@memory, @registers.pc)
  end

  def execute(operation)
    @registers.pc += operation[:length]
    cycles_taken = send("execute_#{operation[:type]}", operation)
    @cycles += cycles_taken
  end

  private

  def execute_NOP(operation)
    operation[:cycles]
  end

  def execute_LD(operation)
    arguments = operation[:arguments]
    @registers.send "#{arguments[0].downcase}=", arguments[1]
    operation[:cycles]
  end

  def execute_XOR(operation)
    @registers.a ^= @registers.send(operation[:arguments][1].downcase)
    @registers.flag_z = @registers.a.zero? ? 1 : 0
    @registers.flag_n = 0
    @registers.flag_c = 0
    @registers.flag_h = 0
    operation[:cycles]
  end
end
