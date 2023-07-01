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
