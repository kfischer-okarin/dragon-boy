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

def test_cpu_execute_operation_ld_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags type: :LD, arguments: [:SP, 0x2345]
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
      given: lambda { |registers, memory|
        registers.a = 0x12
        registers.hl = 0x9FFF
      }
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
      all_flag_combinations.each do |flags|
        registers = Registers.new
        memory = Memory.new
        cpu = CPU.new registers: registers, memory: memory
        given&.call(registers, memory)
        registers.flags = flags

        cpu.execute CPUTests.operation(operation)

        @assert.equal! registers.flags,
                       flags,
                       "Expected flags not to change after #{operation} but " \
                       "they changed from #{flags} to #{registers.flags}"
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
