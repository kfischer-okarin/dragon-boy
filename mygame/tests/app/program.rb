def test_program_parse_operation_without_arguments(_args, assert)
  program = Program.new "\x00"

  operation = program.parse_operation(0)

  assert.equal! operation, { type: :NOP, arguments: [] }
end

def test_program_parse_operation_with_immediate_register_arguments(_args, assert)
  program = Program.new "\x09"

  operation = program.parse_operation(0)

  assert.equal! operation, { type: :ADD, arguments: [:HL, :BC] }
end

def test_program_parse_operation_with_immediate_n8_arguments(_args, assert)
  program = Program.new "\x0E\x42"

  operation = program.parse_operation(0)

  assert.equal! operation, { type: :LD, arguments: [:C, 0x42] }
end

def test_program_parse_operation_with_immediate_n16_arguments(_args, assert)
  program = Program.new "\x21\x42\x33"

  operation = program.parse_operation(0)

  assert.equal! operation, { type: :LD, arguments: [:HL, 0x3342] }
end
