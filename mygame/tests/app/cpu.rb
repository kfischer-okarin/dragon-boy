def test_cpu_execute_advances_pc_by_operation_length(_args, assert)
  [
    CPUTests.operation(type: :NOP, arguments: [], length: 1),
    CPUTests.operation(type: :LD, arguments: [:A, 0x12], length: 2)
  ].each do |operation|
    registers = Registers.new
    memory = Memory.new
    cpu = CPU.new registers: registers, memory: memory
    registers.pc = 0x0123

    cpu.execute operation

    pc_difference = registers.pc - 0x0123
    assert.equal! pc_difference,
                  operation[:length],
                  "Expected PC to be advanced by #{operation[:length]} but was advanced by #{pc_difference}"
  end
end

def test_cpu_execute_advances_cycles_by_operation_cycles(_args, assert)
  [
    CPUTests.operation(type: :NOP, arguments: [], cycles: 4),
    CPUTests.operation(type: :LD, arguments: [:A, 0x12], cycles: 8)
  ].each do |operation|
    registers = Registers.new
    memory = Memory.new
    cpu = CPU.new registers: registers, memory: memory

    cpu.execute operation

    assert.equal! cpu.cycles,
                  operation[:cycles],
                  "Expected cycles to be advanced by #{operation[:cycles]} but was advanced by #{cpu.cycles}"
  end
end

def test_cpu_execute_operation_nop(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :NOP, arguments: [])
  registers_before = registers.to_h
  memory_before = memory.to_a

  cpu.execute operation

  assert.equal! registers.to_h.except(:pc), registers_before.except(:pc)
  assert.equal! memory.to_a, memory_before
end

def test_cpu_execute_operation_nop_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags type: :NOP, arguments: []
  end
end

def test_cpu_execute_operation_ld_constant_into_register(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :LD, arguments: [:SP, 0x2345])

  cpu.execute operation

  assert.equal! registers.sp, 0x2345
end

def test_cpu_execute_operation_ld_register_into_pointer(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :LD, arguments: [Operation::Pointer[:DE], :A])
  registers.a = 0x12
  registers.de = 0xCDEF

  cpu.execute operation

  assert.equal! memory[0xCDEF], 0x12
end

def test_cpu_execute_operation_ld_register_into_0xFF00_pointer(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :LD, arguments: [Operation::Pointer[:C], :A])
  registers.a = 0x12
  registers.c = 0x34

  cpu.execute operation

  assert.equal! memory[0xFF34], 0x12
end

def test_cpu_execute_operation_ld_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags type: :LD, arguments: [:SP, 0x2345]
  end
end

def test_cpu_execute_operation_ldh_A_into_0xFF00_pointer(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :LDH, arguments: [Operation::Pointer[0x80], :A])
  registers.a = 0x99

  cpu.execute operation

  assert.equal! memory[0xFF80], 0x99
end

def test_cpu_execute_operation_ldh_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags type: :LDH, arguments: [Operation::Pointer[0x80], :A]
  end
end

def test_cpu_execute_operation_ldd_a_into_pointer(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :LDD, arguments: [Operation::Pointer[:HL], :A])
  registers.a = 0x12
  registers.hl = 0x9FFF
  memory[0x9FFF] = 0x56

  cpu.execute operation

  assert.equal! memory[0x9FFF], 0x12, 'Expected memory[0x9FFF] to be 0x12 but was 0x%02X' % memory[0x9FFF]
  assert.equal! registers.hl, 0x9FFE, 'Expected HL to be 0x9FFE but was 0x%04X' % registers.hl
end

def test_cpu_execute_operation_ldd_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :LDD, arguments: [Operation::Pointer[:HL], :A] },
      given: lambda { |registers, _memory|
        registers.a = 0x12
        registers.hl = 0x9FFF
      }
    )
  end
end

def test_cpu_execute_operation_inc_8bit_register(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :INC, arguments: [:C])
  registers.c = 0x12

  cpu.execute operation

  assert.equal! registers.c, 0x13

  registers.c = 0xFF

  cpu.execute operation

  assert.equal! registers.c, 0x00
end

def test_cpu_execute_operation_inc_flags(_args, assert)
  CPUTests.test_flags(assert) do
    argument_that_results_not_in_zero = lambda { |registers, _memory|
      registers.e = 0b00100010
    }
    operation_will_set_flags(
      { type: :INC, arguments: [:E] },
      to: { z: 0, n: 0, h: 0 },
      given: argument_that_results_not_in_zero
    )

    argument_that_results_in_zero = lambda { |registers, _memory|
      registers.e = 0b11111111
    }
    operation_will_set_flags(
      { type: :INC, arguments: [:E] },
      to: { z: 1, n: 0, h: 1 }, # bit 3 will overflow into bit 4 so h will be set
      given: argument_that_results_in_zero
    )

    argument_that_results_in_half_carry = lambda { |registers, _memory|
      registers.e = 0b00001111
    }
    operation_will_set_flags(
      { type: :INC, arguments: [:E] },
      to: { h: 1 },
      given: argument_that_results_in_half_carry
    )

    operation_will_ignore_flags(
      { type: :INC, arguments: [:E] },
      [:c]
    )
  end
end

def test_cpu_execute_operation_jr_with_condition_fulfilled(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :JR, arguments: [:NZ, -12], length: 2, cycles: { taken: 12, untaken: 8 })
  registers.pc = 0x0120
  registers.flag_z = 0

  cpu.execute operation

  assert.equal! registers.pc, 0x0120 + 2 - 12
  assert.equal! cpu.cycles, 12
end

def test_cpu_execute_operation_jr_with_condition_not_fulfilled(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = CPUTests.operation(type: :JR, arguments: [:NZ, -12], length: 2, cycles: { taken: 12, untaken: 8 })
  registers.pc = 0x0120
  registers.flag_z = 1

  cpu.execute operation

  assert.equal! registers.pc, 0x0120 + 2
  assert.equal! cpu.cycles, 8
end

def test_cpu_execute_operation_jr_with_condition_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :JR, arguments: [:NZ, -12], cycles: { taken: 12, untaken: 8 } },
    )
  end
end

def test_cpu_execute_operation_xor_register_with_register(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory

  registers.a = 0b00001111
  registers.b = 0b10101010
  operation = CPUTests.operation(type: :XOR, arguments: [:A, :B])

  cpu.execute operation

  assert.equal! registers.a, 0b10100101
end

def test_cpu_execute_operation_xor_flags(_args, assert)
  CPUTests.test_flags(assert) do
    arguments_that_result_not_in_zero = lambda { |registers, _memory|
      registers.a = 0b10000000
      registers.b = 0b00000000
    }
    operation_will_set_flags(
      { type: :XOR, arguments: [:A, :B] },
      to: { z: 0, n: 0, h: 0, c: 0 },
      given: arguments_that_result_not_in_zero
    )

    arguments_that_result_in_zero = lambda { |registers, _memory|
      registers.a = 0b10000000
      registers.b = 0b10000000
    }
    operation_will_set_flags(
      { type: :XOR, arguments: [:A, :B] },
      to: { z: 1, n: 0, h: 0, c: 0 },
      given: arguments_that_result_in_zero
    )
  end
end

def test_cpu_execute_operation_bit_on_register(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_set_flags(
      { type: :BIT, arguments: [7, :H] },
      to: { z: 1, n: 0, h: 1 },
      given: lambda { |registers, _memory|
        registers.h = 0b01111111
      }
    )

    operation_will_set_flags(
      { type: :BIT, arguments: [6, :L] },
      to: { z: 0, n: 0, h: 1 },
      given: lambda { |registers, _memory|
        registers.l = 0b01000000
      }
    )

    operation_will_ignore_flags(
      { type: :BIT, arguments: [5, :C] },
      [:c],
      given: lambda { |registers, _memory|
        registers.c = 0b00000000
      }
    )
  end
end

def test_cpu_execute_next_operation(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  memory.load_rom "\x00\x00\x02"
  registers.pc = 0x0002

  executed_operation = nil
  cpu.define_singleton_method :execute do |operation|
    executed_operation = operation
  end

  cpu.execute_next_operation

  assert.equal! executed_operation[:opcode], 0x02
end

module CPUTests
  class << self
    def operation(operation)
      # Add some defaults so that execute doesn't fail
      { length: 1, cycles: 4, opcode: 0x00 }.merge operation
    end

    def test_flags(assert, &block)
      FlagsTestDSL.new(assert).instance_eval(&block)
    end
  end

  class FlagsTestDSL
    def initialize(assert)
      @assert = assert
    end

    def operation_will_not_change_any_flags(operation, given: nil)
      operation_will_ignore_flags operation, %i[z n h c], given: given
    end

    def operation_will_ignore_flags(operation, ignored_flags, given: nil)
      all_flag_combinations.each do |flags|
        registers = Registers.new
        memory = Memory.new
        cpu = CPU.new registers: registers, memory: memory
        given&.call(registers, memory)
        registers.flags = flags

        cpu.execute CPUTests.operation(operation)

        actual_flags = registers.flags.slice(*ignored_flags)
        @assert.equal! actual_flags,
                       flags.slice(*ignored_flags),
                       "Expected flags #{ignored_flags} not to change after executing #{operation} but " \
                       "they changed from #{flags} to #{actual_flags}"
      end
    end

    def operation_will_set_flags(operation, to:, given: nil)
      all_flag_combinations.each do |flags|
        registers = Registers.new
        memory = Memory.new
        cpu = CPU.new registers: registers, memory: memory
        given&.call(registers, memory)
        registers.flags = flags

        cpu.execute CPUTests.operation(operation)

        actual_flags = registers.flags.slice(*to.keys)
        @assert.equal! actual_flags,
                       to,
                       "Expected flags with values #{to} after executing #{operation} but " \
                       "they changed had values #{actual_flags}"
      end
    end

    def all_flag_combinations
      [
        { z: 0, n: 0, h: 0, c: 0 },
        { z: 0, n: 0, h: 0, c: 1 },
        { z: 0, n: 0, h: 1, c: 0 },
        { z: 0, n: 0, h: 1, c: 1 },
        { z: 0, n: 1, h: 0, c: 0 },
        { z: 0, n: 1, h: 0, c: 1 },
        { z: 0, n: 1, h: 1, c: 0 },
        { z: 0, n: 1, h: 1, c: 1 },
        { z: 1, n: 0, h: 0, c: 0 },
        { z: 1, n: 0, h: 0, c: 1 },
        { z: 1, n: 0, h: 1, c: 0 },
        { z: 1, n: 0, h: 1, c: 1 },
        { z: 1, n: 1, h: 0, c: 0 },
        { z: 1, n: 1, h: 0, c: 1 },
        { z: 1, n: 1, h: 1, c: 0 },
        { z: 1, n: 1, h: 1, c: 1 }
      ]
    end
  end
end
