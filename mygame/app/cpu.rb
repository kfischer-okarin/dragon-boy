class CPU
  attr_reader :cycles

  CYCLES_PER_SECOND = 4_194_304

  def initialize(registers:, memory:)
    @registers = registers
    @memory = memory
    @cycles = 0
  end

  def execute_next_operation
    operation = Operation.parse(@memory, @registers.pc)
    @registers.pc += operation[:length]
    execute operation
  end

  def execute(operation)
    cycles_taken = send("execute_#{operation[:type]}", operation)
    @cycles += cycles_taken
  end

  private

  def execute_NOP(operation)
    operation[:cycles]
  end

  def execute_LD(operation)
    target = operation[:arguments][0]
    value = source_value operation[:arguments][1]

    case target
    when Operation::Pointer
      address = target.address
      address = @registers.send(address.downcase) if address.is_a? Symbol
      address += 0xFF00 if target.address == :C
      @memory[address] = value
    else
      @registers.send "#{target.downcase}=", value
    end
    operation[:cycles]
  end

  def execute_LDH(operation)
    target = operation[:arguments][0]
    case target
    when Operation::Pointer
      address = 0xFF00 + target.address
      @memory[address] = @registers.a
    end
    operation[:cycles]
  end

  def execute_LDI(operation)
    @memory[@registers.hl] = @registers.a
    @registers.hl += 1
    operation[:cycles]
  end

  def execute_LDD(operation)
    @memory[@registers.hl] = @registers.a
    @registers.hl -= 1
    operation[:cycles]
  end

  def execute_INC(operation)
    register = operation[:arguments][0].downcase
    case register
    when :a, :b, :c, :d, :e, :h, :l
      old_value = @registers.send(register)
      result = (old_value + 1) & 0xFF
      @registers.flag_n = 0
      assign_flag_z result
      assign_flag_h old_value, result
    when :bc, :de, :hl, :sp
      result = @registers.send(register) + 1 & 0xFFFF
    end

    @registers.send "#{register}=", result
    operation[:cycles]
  end

  def execute_DEC(operation)
    register = operation[:arguments][0].downcase
    old_value = @registers.send(register)
    result = old_value - 1 & 0xFF
    @registers.send "#{register}=", result

    @registers.flag_n = 1
    assign_flag_z result
    assign_flag_h old_value, result
    operation[:cycles]
  end

  def execute_CALL(operation)
    push_16bit_value @registers.pc
    @registers.pc = operation[:arguments][0]
    operation[:cycles]
  end

  def execute_RET(operation)
    @registers.pc = pop_16bit_value
    operation[:cycles]
  end

  def execute_PUSH(operation)
    push_16bit_value @registers.send(operation[:arguments][0].downcase)
    operation[:cycles]
  end

  def execute_POP(operation)
    value = pop_16bit_value
    @registers.send "#{operation[:arguments][0].downcase}=", value
    operation[:cycles]
  end

  def execute_JR(operation)
    arguments = operation[:arguments]
    case arguments[0]
    when Symbol
      if condition_fulfilled? arguments[0]
        @registers.pc += arguments[1]
        operation[:cycles][:taken]
      else
        operation[:cycles][:untaken]
      end
    else
      @registers.pc += arguments[0]
      operation[:cycles]
    end
  end

  def execute_XOR(operation)
    @registers.a ^= @registers.send(operation[:arguments][1].downcase)
    assign_flag_z @registers.a
    @registers.flag_n = 0
    @registers.flag_c = 0
    @registers.flag_h = 0
    operation[:cycles]
  end

  def execute_RLA(operation)
    execute_RL operation.merge(arguments: [:A])
    operation[:cycles]
  end

  def execute_RL(operation)
    register = operation[:arguments][0].downcase
    value = @registers.send(register)
    result = ((value << 1) | @registers.flag_c) & 0xFF
    @registers.send("#{register}=", result)
    assign_flag_z result
    @registers.flag_n = 0
    assign_flag_c value, result
    @registers.flag_h = 0
    operation[:cycles]
  end

  def execute_BIT(operation)
    bit = operation[:arguments][0]
    register = operation[:arguments][1].downcase
    result = @registers.send(register) & (1 << bit)
    assign_flag_z result
    @registers.flag_n = 0
    @registers.flag_h = 1
    operation[:cycles]
  end

  def execute_CP(operation)
    argument = operation[:arguments][1]
    value = argument
    difference = (@registers.a - value) & 0xFF
    assign_flag_z difference
    @registers.flag_n = 1
    assign_flag_c @registers.a, difference
    assign_flag_h @registers.a, difference
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

  def push_16bit_value(value)
    push((value & 0xFF00) >> 8)
    push(value & 0x00FF)
  end

  def push(value)
    @registers.sp -= 1
    @memory[@registers.sp] = value
  end

  def pop_16bit_value
    pop + (pop << 8)
  end

  def pop
    result = @memory[@registers.sp]
    @registers.sp += 1
    result
  end

  def source_value(source)
    case source
    when Operation::Pointer
      @memory[@registers.send(source.address.downcase)]
    when Symbol
      @registers.send(source.downcase)
    else
      source
    end
  end

  def assign_flag_z(result)
    @registers.flag_z = result.zero? ? 1 : 0
  end

  def assign_flag_c(old_value, new_value)
    @registers.flag_c = if @registers.flag_n.zero?
                          new_value < old_value ? 1 : 0
                        else
                          new_value > old_value ? 1 : 0
                        end
  end

  def assign_flag_h(old_value, new_value)
    @registers.flag_h = if @registers.flag_n.zero?
                          (new_value & 0xF) < (old_value & 0xF) ? 1 : 0
                        else
                          (new_value & 0xF) > (old_value & 0xF) ? 1 : 0
                        end
  end
end
