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
    if operation[:arguments][0] == Operation::Pointer[:C]
      @memory[0xFF00 + @registers.c] = @registers.send(operation[:arguments][1].downcase)
    else
      arguments = operation[:arguments]
      @registers.send "#{arguments[0].downcase}=", arguments[1]
    end
    operation[:cycles]
  end

  def execute_LDD(operation)
    @memory[@registers.hl] = @registers.a
    @registers.hl -= 1
    operation[:cycles]
  end

  def execute_INC(operation)
    register = operation[:arguments][0].downcase
    result = @registers.send(register) + 1 & 0xFF
    @registers.send "#{register}=", result

    @registers.flag_z = result.zero? ? 1 : 0
    @registers.flag_n = 0
    @registers.flag_h = (@registers.send(register) & 0xF).zero? ? 1 : 0
    operation[:cycles]
  end

  def execute_JR(operation)
    if condition_fulfilled? operation[:arguments][0]
      @registers.pc += operation[:arguments][1]
      operation[:cycles][:taken]
    else
      operation[:cycles][:untaken]
    end
  end

  def execute_XOR(operation)
    @registers.a ^= @registers.send(operation[:arguments][1].downcase)
    @registers.flag_z = @registers.a.zero? ? 1 : 0
    @registers.flag_n = 0
    @registers.flag_c = 0
    @registers.flag_h = 0
    operation[:cycles]
  end

  def execute_BIT(operation)
    bit = operation[:arguments][0]
    register = operation[:arguments][1].downcase
    @registers.flag_z = (@registers.send(register) & (1 << bit)).zero? ? 1 : 0
    @registers.flag_n = 0
    @registers.flag_h = 1
    operation[:cycles]
  end

  def condition_fulfilled?(condition)
    case condition
    when :NZ
      @registers.flag_z.zero?
    when :Z
      @registers.flag_z == 1
    when :NC
      @registers.flag_c.zero?
    when :C
      @registers.flag_c == 1
    end
  end
end
