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
