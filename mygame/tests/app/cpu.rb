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

def test_cpu_execute_operation_nop(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = { type: :NOP, arguments: [], length: 1, cycles: 4, opcode: 0x00 }

  cpu.execute operation

  assert.equal! registers.pc, 0x0001
  assert.equal! cpu.cycles, 4
end

def test_cpu_execute_operation_ld_constant_into_register(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory
  operation = { type: :LD, arguments: [:SP, 0x2345], length: 3, cycles: 12, opcode: 0x31 }

  cpu.execute operation

  assert.equal! registers.sp, 0x2345
  assert.equal! cpu.cycles, 12
end

def test_cpu_execute_operation_xor_register_with_register(_args, assert)
  registers = Registers.new
  memory = Memory.new
  cpu = CPU.new registers: registers, memory: memory

  registers.a = 0b00001111
  registers.b = 0b10101010
  registers.f = 0b11110000 # all flags 1
  operation = { type: :XOR, arguments: [:A, :B], length: 1, cycles: 4, opcode: 0xA8 }

  cpu.execute operation

  assert.equal! registers.a, 0b10100101
  assert.equal! registers.flag_z, 0 # because result was not 0
  assert.equal! registers.flag_n, 0
  assert.equal! registers.flag_h, 0
  assert.equal! registers.flag_c, 0
  assert.equal! cpu.cycles, 4
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
  end
end
