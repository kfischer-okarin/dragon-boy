[
  {
    name: :operation_without_arguments,
    program_code: "\x00",
    expected: { type: :NOP, arguments: [] }
  },
  {
    name: :operation_with_immediate_register_arguments,
    program_code: "\x09",
    expected: { type: :ADD, arguments: [:HL, :BC] }
  },
  {
    name: :operation_with_immediate_n8_arguments,
    program_code: "\x06\x42",
    expected: { type: :LD, arguments: [:B, 0x42] }
  },
  {
    name: :operation_with_immediate_n16_arguments,
    program_code: "\x21\x42\x33",
    expected: { type: :LD, arguments: [:HL, 0x3342] }
  },
  {
    name: :operation_with_nonimmediate_register_arguments,
    program_code: "\x02",
    expected: { type: :LD, arguments: [:BC_as_pointer, :A] }
  }
].each do |test_case|
  define_method "test_program_parse_#{test_case[:name]}" do |_args, assert|
    program = Program.new test_case[:program_code]

    operation = program.parse_operation(0)

    assert.equal! operation, test_case[:expected]
  end
end
