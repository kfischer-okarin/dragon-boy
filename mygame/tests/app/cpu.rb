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
  assert.equal! registers.pc, 0x0003
  assert.equal! cpu.cycles, 12
end
