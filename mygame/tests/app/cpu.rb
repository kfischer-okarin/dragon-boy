require 'tests/test_helper.rb'

def test_cpu_execute_operation_nop(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :NOP, arguments: [])
  registers_before = cpu.registers.to_h
  memory_before = cpu.memory.to_a

  cpu.execute operation

  assert.equal! cpu.registers.to_h.except(:pc), registers_before.except(:pc)
  assert.equal! cpu.memory.to_a, memory_before
end

def test_cpu_execute_operation_nop_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags type: :NOP, arguments: []
  end
end

def test_cpu_execute_operation_ld_constant_into_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LD, arguments: [:SP, 0x2345])

  cpu.execute operation

  assert.equal! cpu.registers.sp, 0x2345
end

def test_cpu_execute_operation_ld_register_into_pointer(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LD, arguments: [Operation::Pointer[:DE], :A])
  cpu.registers.a = 0x12
  cpu.registers.de = 0xCDEF

  cpu.execute operation

  assert.equal! cpu.memory[0xCDEF], 0x12
end

def test_cpu_execute_operation_ld_pointer_into_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LD, arguments: [:A, Operation::Pointer[:DE]])
  cpu.registers.de = 0xCDEF
  cpu.memory[0xCDEF] = 0x12

  cpu.execute operation

  assert.equal! cpu.registers.a, 0x12
end

def test_cpu_execute_operation_ld_register_into_constant_pointer(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LD, arguments: [Operation::Pointer[0x9910], :A])
  cpu.registers.a = 0x12

  cpu.execute operation

  assert.equal! cpu.memory[0x9910], 0x12
end

def test_cpu_execute_operation_ld_register_into_0xFF00_pointer(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LD, arguments: [Operation::Pointer[:C], :A])
  cpu.registers.a = 0x12
  cpu.registers.c = 0x34

  cpu.execute operation

  assert.equal! cpu.memory[0xFF34], 0x12
end

def test_cpu_execute_operation_ld_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags type: :LD, arguments: [:SP, 0x2345]
  end
end

def test_cpu_execute_operation_ldh_A_into_0xFF00_pointer(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LDH, arguments: [Operation::Pointer[0x80], :A])
  cpu.registers.a = 0x99

  cpu.execute operation

  assert.equal! cpu.memory[0xFF80], 0x99
end

def test_cpu_execute_operation_ldh_0xFF00_pointer_into_A(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LDH, arguments: [:A, Operation::Pointer[0x80]])
  cpu.memory[0xFF80] = 0x99

  cpu.execute operation

  assert.equal! cpu.registers.a, 0x99
end

def test_cpu_execute_operation_ldh_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags type: :LDH, arguments: [Operation::Pointer[0x80], :A]
  end
end

def test_cpu_execute_operation_ldi_a_into_pointer(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LDI, arguments: [Operation::Pointer[:HL], :A])
  cpu.registers.a = 0x12
  cpu.registers.hl = 0x9FFF
  cpu.memory[0x9FFF] = 0x56

  cpu.execute operation

  assert.equal! cpu.memory[0x9FFF], 0x12, 'Expected memory[0x9FFF] to be 0x12 but was 0x%02X' % cpu.memory[0x9FFF]
  assert.equal! cpu.registers.hl, 0xA000, 'Expected HL to be 0xA000 but was 0x%04X' % cpu.registers.hl
end

def test_cpu_execute_operation_ldi_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :LDI, arguments: [Operation::Pointer[:HL], :A] },
      given: lambda { |registers, _memory|
        registers.a = 0x12
        registers.hl = 0x9FFF
      }
    )
  end
end

def test_cpu_execute_operation_ldd_a_into_pointer(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :LDD, arguments: [Operation::Pointer[:HL], :A])
  cpu.registers.a = 0x12
  cpu.registers.hl = 0x9FFF
  cpu.memory[0x9FFF] = 0x56

  cpu.execute operation

  assert.equal! cpu.memory[0x9FFF], 0x12, 'Expected memory[0x9FFF] to be 0x12 but was 0x%02X' % cpu.memory[0x9FFF]
  assert.equal! cpu.registers.hl, 0x9FFE, 'Expected HL to be 0x9FFE but was 0x%04X' % cpu.registers.hl
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

def test_cpu_execute_operation_sub_8bit_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :SUB, arguments: [:A, :B])
  cpu.registers.a = 0x34
  cpu.registers.b = 0x33

  cpu.execute operation

  assert.equal! cpu.registers.a, 0x01
end

def test_cpu_execute_operation_sub_8bit_register_overflow(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :SUB, arguments: [:A, :B])
  cpu.registers.a = 0x34
  cpu.registers.b = 0x35

  cpu.execute operation

  assert.equal! cpu.registers.a, 0xFF
end

def test_cpu_execute_operation_sub_flags(_args, assert)
  CPUTests.test_flags(assert) do
    arguments_that_result_not_in_zero = lambda { |registers, _memory|
      registers.a = 0x34
      registers.e = 0x33
    }
    operation_will_set_flags(
      { type: :SUB, arguments: [:A, :E] },
      to: { z: 0, n: 1 },
      given: arguments_that_result_not_in_zero
    )

    arguments_that_result_in_zero = lambda { |registers, _memory|
      registers.a = 0x34
      registers.e = 0x34
    }
    operation_will_set_flags(
      { type: :SUB, arguments: [:A, :E] },
      to: { z: 1, n: 1 },
      given: arguments_that_result_in_zero
    )

    arguments_that_result_in_half_carry = lambda { |registers, _memory|
      registers.a = 0x10
      registers.e = 0x01
    }
    operation_will_set_flags(
      { type: :SUB, arguments: [:A, :E] },
      to: { h: 1, n: 1 },
      given: arguments_that_result_in_half_carry
    )

    arguments_that_result_in_carry = lambda { |registers, _memory|
      registers.a = 0x01
      registers.e = 0x10
    }
    operation_will_set_flags(
      { type: :SUB, arguments: [:A, :E] },
      to: { c: 1, n: 1 },
      given: arguments_that_result_in_carry
    )
  end
end


def test_cpu_execute_operation_inc_8bit_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :INC, arguments: [:C])
  cpu.registers.c = 0x12

  cpu.execute operation

  assert.equal! cpu.registers.c, 0x13

  cpu.registers.c = 0xFF

  cpu.execute operation

  assert.equal! cpu.registers.c, 0x00
end

def test_cpu_execute_operation_inc_8bit_register_flags(_args, assert)
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

def test_cpu_execute_operation_inc_16bit_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :INC, arguments: [:BC])
  cpu.registers.bc = 0x1234

  cpu.execute operation

  assert.equal! cpu.registers.bc, 0x1235

  cpu.registers.bc = 0xFFFF

  cpu.execute operation

  assert.equal! cpu.registers.bc, 0x0000
end

def test_cpu_execute_operation_inc_16bit_register_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(type: :INC, arguments: [:DE])
  end
end

def test_cpu_execute_operation_dec_8bit_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :DEC, arguments: [:C])
  cpu.registers.c = 0x12

  cpu.execute operation

  assert.equal! cpu.registers.c, 0x11

  cpu.registers.c = 0x00

  cpu.execute operation

  assert.equal! cpu.registers.c, 0xFF
end

def test_cpu_execute_operation_dec_flags(_args, assert)
  CPUTests.test_flags(assert) do
    argument_that_results_not_in_zero = lambda { |registers, _memory|
      registers.e = 0b00100010
    }
    operation_will_set_flags(
      { type: :DEC, arguments: [:E] },
      to: { z: 0, n: 1, h: 0 },
      given: argument_that_results_not_in_zero
    )

    argument_that_results_in_zero = lambda { |registers, _memory|
      registers.e = 0b00000001
    }
    operation_will_set_flags(
      { type: :DEC, arguments: [:E] },
      to: { z: 1, n: 1, h: 0 },
      given: argument_that_results_in_zero
    )

    argument_that_results_in_half_carry = lambda { |registers, _memory|
      registers.e = 0b00010000
    }
    operation_will_set_flags(
      { type: :DEC, arguments: [:E] },
      to: { h: 1 },
      given: argument_that_results_in_half_carry
    )

    operation_will_ignore_flags(
      { type: :DEC, arguments: [:E] },
      [:c]
    )
  end
end

def test_cpu_execute_operation_jr(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :JR, arguments: [-13])
  cpu.registers.pc = 0x0120

  cpu.execute operation

  assert.equal! cpu.registers.pc, 0x0120 - 13
end

def test_cpu_execute_operation_jr_with_condition_fulfilled(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :JR, arguments: [:NZ, -12])
  cpu.registers.pc = 0x0120
  cpu.registers.flag_z = 0

  cpu.execute operation

  assert.equal! cpu.registers.pc, 0x0120 - 12
end

def test_cpu_execute_operation_jr_with_condition_not_fulfilled(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :JR, arguments: [:NZ, -12])
  cpu.registers.pc = 0x0120
  cpu.registers.flag_z = 1

  cpu.execute operation

  assert.equal! cpu.registers.pc, 0x0120
end

def test_cpu_execute_operation_jr_with_condition_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :JR, arguments: [:NZ, -12] }
    )
  end
end

def test_cpu_execute_operation_call(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :CALL, arguments: [0x0095])
  cpu.registers.pc = 0x0120
  cpu.registers.sp = 0xFFFE

  cpu.execute operation

  assert.equal! cpu.registers.pc, 0x0095
  assert.equal! cpu.registers.sp, 0xFFFC
  assert.equal! cpu.memory[0xFFFC], 0x20
  assert.equal! cpu.memory[0xFFFD], 0x01
end

def test_cpu_execute_operation_call_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :CALL, arguments: [0x0095] }
    )
  end
end

def test_cpu_execute_operation_ret(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :RET, arguments: [])
  cpu.registers.pc = 0x0120
  cpu.registers.sp = 0xFFFC
  cpu.memory[0xFFFC] = 0x45
  cpu.memory[0xFFFD] = 0x03

  cpu.execute operation

  assert.equal! cpu.registers.pc, 0x0345
  assert.equal! cpu.registers.sp, 0xFFFE
end

def test_cpu_execute_operation_ret_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :RET, arguments: [] },
      given: lambda { |registers, memory|
        registers.sp = 0xFFFC
        memory[0xFFFC] = 0x45
        memory[0xFFFD] = 0x03
      }
    )
  end
end

def test_cpu_execute_operation_push_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :PUSH, arguments: [:BC])
  cpu.registers.bc = 0x1234
  cpu.registers.sp = 0xFFFE

  cpu.execute operation

  assert.equal! cpu.registers.sp, 0xFFFC
  assert.equal! cpu.memory[0xFFFC], 0x34
  assert.equal! cpu.memory[0xFFFD], 0x12
end

def test_cpu_execute_operation_push_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :PUSH, arguments: [:BC] },
      given: lambda { |registers, _memory|
        registers.bc = 0x1234
        registers.sp = 0xFFFE
      }
    )
  end
end

def test_cpu_execute_operation_pop_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :POP, arguments: [:BC])
  cpu.registers.sp = 0xFFFC
  cpu.memory[0xFFFC] = 0x34
  cpu.memory[0xFFFD] = 0x12

  cpu.execute operation

  assert.equal! cpu.registers.sp, 0xFFFE
  assert.equal! cpu.registers.bc, 0x1234
end

def test_cpu_execute_operation_pop_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_not_change_any_flags(
      { type: :POP, arguments: [:BC] },
      given: lambda { |registers, memory|
        registers.sp = 0xFFFC
        memory[0xFFFC] = 0x34
        memory[0xFFFD] = 0x12
      }
    )
  end
end

def test_cpu_execute_operation_xor_register_with_register(_args, assert)
  cpu = build_cpu

  cpu.registers.a = 0b00001111
  cpu.registers.b = 0b10101010
  operation = CPUTests.operation(type: :XOR, arguments: [:A, :B])

  cpu.execute operation

  assert.equal! cpu.registers.a, 0b10100101
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

def test_cpu_execute_operation_rl_on_register(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :RL, arguments: [:C])
  cpu.registers.c = 0b10110100
  cpu.registers.flag_c = 1

  cpu.execute operation

  assert.equal! cpu.registers.c, 0b01101001
  assert.equal! cpu.registers.flag_c, 1
end

def test_cpu_execute_operation_rl_on_ff(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :RL, arguments: [:C])
  cpu.registers.c = 0b11111111
  cpu.registers.flag_c = 1

  cpu.execute operation

  assert.equal! cpu.registers.c, 0b11111111
  assert.equal! cpu.registers.flag_c, 1
end

def test_cpu_execute_operation_rl_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_set_flags(
      { type: :RL, arguments: [:A] },
      to: { c: 1, z: 0, n: 0, h: 0 },
      given: lambda { |registers, _memory|
        registers.a = 0b10000000
        registers.flag_c = 1
      }
    )
    operation_will_set_flags(
      { type: :RL, arguments: [:A] },
      to: { c: 0, z: 1, n: 0, h: 0 },
      given: lambda { |registers, _memory|
        registers.a = 0b00000000
        registers.flag_c = 0
      }
    )
  end
end

def test_cpu_execute_operation_rla(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :RLA, arguments: [])
  cpu.registers.a = 0b10110100
  cpu.registers.flag_c = 1

  cpu.execute operation

  assert.equal! cpu.registers.a, 0b01101001
  assert.equal! cpu.registers.flag_c, 1
end

def test_cpu_execute_operation_rla_on_ff(_args, assert)
  cpu = build_cpu
  operation = CPUTests.operation(type: :RLA, arguments: [])
  cpu.registers.a = 0b11111111
  cpu.registers.flag_c = 1

  cpu.execute operation

  assert.equal! cpu.registers.a, 0b11111111
  assert.equal! cpu.registers.flag_c, 1
end

def test_cpu_execute_operation_rla_flags(_args, assert)
  CPUTests.test_flags(assert) do
    operation_will_set_flags(
      { type: :RLA, arguments: [] },
      to: { c: 1, z: 0, n: 0, h: 0 },
      given: lambda { |registers, _memory|
        registers.a = 0b10000000
        registers.flag_c = 1
      }
    )
    operation_will_set_flags(
      { type: :RLA, arguments: [] },
      to: { c: 0, z: 1, n: 0, h: 0 },
      given: lambda { |registers, _memory|
        registers.a = 0b00000000
        registers.flag_c = 0
      }
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

def test_cpu_execute_operation_cp_with_constant(_args, assert)
  CPUTests.test_flags(assert) do
    a_equal_to_argument = lambda { |registers, _memory|
      registers.a = 0x34 # 0b00110100
    }
    operation_will_set_flags(
      { type: :CP, arguments: [:A, 0x34] },
      to: { z: 1, n: 1, c: 0 },
      given: a_equal_to_argument
    )

    a_bigger_than_argument = lambda { |registers, _memory|
      registers.a = 0x34 # 0b00110100
    }
    operation_will_set_flags(
      { type: :CP, arguments: [:A, 0x33] },
      to: { z: 0, n: 1, c: 0 },
      given: a_bigger_than_argument
    )

    a_smaller_than_argument = lambda { |registers, _memory|
      registers.a = 0x34 # 0b00110100
    }
    operation_will_set_flags(
      { type: :CP, arguments: [:A, 0x35] },
      to: { z: 0, n: 1, c: 1 },
      given: a_smaller_than_argument
    )

    arguments_that_cause_half_carry = lambda { |registers, _memory|
      registers.a = 0x10 # 0b00010000
    }
    operation_will_set_flags(
      { type: :CP, arguments: [:A, 0x01] },
      to: { h: 1 },
      given: arguments_that_cause_half_carry
    )

    arguments_that_do_not_cause_half_carry = lambda { |registers, _memory|
      registers.a = 0x10 # 0b00010000
    }
    operation_will_ignore_flags(
      { type: :CP, arguments: [:A, 0x10] },
      to: { h: 0 },
      given: arguments_that_do_not_cause_half_carry
    )
  end
end

def test_cpu_execute_next_operation_executes_operation_at_pc(_args, assert)
  cpu = build_cpu
  cpu.memory.load_rom "\x00\x00\x02"
  cpu.registers.pc = 0x0002

  executed_operation = nil
  cpu.define_singleton_method :execute do |operation|
    executed_operation = operation
  end

  cpu.execute_next_operation

  assert.equal! executed_operation[:opcode], 0x02
end

def test_cpu_execute_next_operation_executes_advances_pc(_args, assert)
  cpu = build_cpu
  cpu.memory.load_rom "\x00\x00\x02"
  cpu.registers.pc = 0x0002

  cpu.execute_next_operation

  assert.equal! cpu.registers.pc, 0x0003 # See opcodes.json:45
end

def test_cpu_next_operation(_args, assert)
  cpu = build_cpu
  cpu.memory.load_rom "\x00\x02"
  cpu.registers.pc = 0x0000

  assert.equal! cpu.next_operation[:opcode], 0x00

  cpu.execute_next_operation

  assert.equal! cpu.next_operation[:opcode], 0x02
end

def test_cpu_next_operation_duration_non_jump(_args, assert)
  cpu = build_cpu
  cpu.define_singleton_method :next_operation do
    { type: :NOP, arguments: [], cycles: 16 }
  end

  assert.equal! cpu.next_operation_duration, 16
end

def test_cpu_next_operation_duration_conditional_jump(_args, assert)
  cpu = build_cpu
  [:JR, :JP, :CALL, :RET].each do |type|
    cpu.define_singleton_method :next_operation do
      { type: type, arguments: [:Z], cycles: { taken: 20, untaken: 8 } }
    end
    cpu.registers.flag_z = 1

    assert.equal! cpu.next_operation_duration, 20

    cpu.registers.flag_z = 0

    assert.equal! cpu.next_operation_duration, 8
  end
end

def test_cpu_next_operation_duration_unconditional_jump(_args, assert)
  cpu = build_cpu
  [:JR, :JP, :CALL, :RET].each do |type|
    cpu.define_singleton_method :next_operation do
      { type: type, arguments: [], cycles: 20 }
    end

    assert.equal! cpu.next_operation_duration, 20
  end
end

module CPUTests
  class << self
    def operation(operation)
      # Add some defaults so that execute doesn't fail
      { length: 1, opcode: 0x00 }.merge operation
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
        cpu = build_cpu
        cpu.registers.flags = flags
        given&.call(cpu.registers, cpu.memory)

        cpu.execute CPUTests.operation(operation)

        actual_flags = cpu.registers.flags.slice(*ignored_flags)
        @assert.equal! actual_flags,
                       flags.slice(*ignored_flags),
                       "Expected flags #{ignored_flags} not to change after executing #{operation} but " \
                       "they changed from #{flags} to #{actual_flags}"
      end
    end

    def operation_will_set_flags(operation, to:, given: nil)
      all_flag_combinations.each do |flags|
        cpu = build_cpu
        cpu.registers.flags = flags
        given&.call(cpu.registers, cpu.memory)

        cpu.execute CPUTests.operation(operation)

        actual_flags = cpu.registers.flags.slice(*to.keys)
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
