class CPU
  attr_reader :registers, :memory

  def initialize(registers:, memory:)
    @registers = registers
    @memory = memory
  end

  def execute_next_operation
    operation = next_operation
    @registers.pc += operation[:length]
    @next_operation = nil
    execute operation
  end

  def next_operation_duration
    cycles = next_operation[:cycles]
    case cycles
    when Hash
      if condition_fulfilled? next_operation[:arguments][0]
        cycles[:taken]
      else
        cycles[:untaken]
      end
    else
      cycles
    end
  end

  def next_operation
    @next_operation ||= Operation.parse(@memory, @registers.pc)
  end

  def execute(operation)
    send("execute_#{operation[:type]}", operation)
  end

  private

  def execute_NOP(operation)
    # Do nothing
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
  end

  def execute_LDH(operation)
    target = operation[:arguments][0]
    case target
    when Operation::Pointer
      address = 0xFF00 + target.address
      @memory[address] = @registers.a
    when Symbol
      @registers.a = @memory[0xFF00 + operation[:arguments][1].address]
    end
  end

  def execute_LDI(operation)
    @memory[@registers.hl] = @registers.a
    @registers.hl += 1
  end

  def execute_LDD(operation)
    @memory[@registers.hl] = @registers.a
    @registers.hl -= 1
  end

  def execute_SUB(operation)
    old_value = @registers.a
    @registers.a = (@registers.a - source_value(operation[:arguments][1])) & 0xFF
    @registers.flag_n = 1
    assign_flag_z @registers.a
    assign_flag_c old_value, @registers.a
    assign_flag_h old_value, @registers.a
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
  end

  def execute_DEC(operation)
    register = operation[:arguments][0].downcase
    old_value = @registers.send(register)
    result = old_value - 1 & 0xFF
    @registers.send "#{register}=", result

    @registers.flag_n = 1
    assign_flag_z result
    assign_flag_h old_value, result
  end

  def execute_CALL(operation)
    push_16bit_value @registers.pc
    @registers.pc = operation[:arguments][0]
  end

  def execute_RET(operation)
    @registers.pc = pop_16bit_value
  end

  def execute_PUSH(operation)
    push_16bit_value @registers.send(operation[:arguments][0].downcase)
  end

  def execute_POP(operation)
    value = pop_16bit_value
    @registers.send "#{operation[:arguments][0].downcase}=", value
  end

  def execute_JR(operation)
    arguments = operation[:arguments]
    case arguments[0]
    when Symbol
      @registers.pc += arguments[1] if condition_fulfilled? arguments[0]
    else
      @registers.pc += arguments[0]
    end
  end

  def execute_XOR(operation)
    @registers.a ^= @registers.send(operation[:arguments][1].downcase)
    assign_flag_z @registers.a
    @registers.flag_n = 0
    @registers.flag_c = 0
    @registers.flag_h = 0
  end

  def execute_RLA(operation)
    execute_RL operation.merge(arguments: [:A])
  end

  def execute_RL(operation)
    register = operation[:arguments][0].downcase
    value = @registers.send(register)
    result = ((value << 1) | @registers.flag_c) & 0xFF
    @registers.send("#{register}=", result)
    assign_flag_z result
    @registers.flag_n = 0
    @registers.flag_c = value >> 7
    @registers.flag_h = 0
  end

  def execute_BIT(operation)
    bit = operation[:arguments][0]
    register = operation[:arguments][1].downcase
    result = @registers.send(register) & (1 << bit)
    assign_flag_z result
    @registers.flag_n = 0
    @registers.flag_h = 1
  end

  def execute_CP(operation)
    argument = operation[:arguments][1]
    value = argument
    difference = (@registers.a - value) & 0xFF
    assign_flag_z difference
    @registers.flag_n = 1
    assign_flag_c @registers.a, difference
    assign_flag_h @registers.a, difference
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
