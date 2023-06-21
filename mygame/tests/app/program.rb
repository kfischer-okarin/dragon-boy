def test_program_parse_operation_nop(_args, assert)
  program = Program.new "\x00"

  operation = program.parse_operation(0)

  assert.equal! operation, { type: :nop, arguments: [], length: 1 }
end
