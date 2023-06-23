[
  {
    name: :without_arguments,
    program_code: "\x00",
    expected: { type: :NOP, arguments: [] }
  },
  {
    name: :with_immediate_register_arguments,
    program_code: "\x09",
    expected: { type: :ADD, arguments: [:HL, :BC] }
  },
  {
    name: :with_immediate_n8_arguments,
    program_code: "\x06\x42",
    expected: { type: :LD, arguments: [:B, 0x42] }
  },
  {
    name: :with_immediate_n16_arguments,
    program_code: "\x21\x42\x33",
    expected: { type: :LD, arguments: [:HL, 0x3342] }
  },
  {
    name: :with_nonimmediate_register_arguments,
    program_code: "\x02",
    expected: { type: :LD, arguments: [Program::Pointer[:BC], :A] }
  },
  {
    name: :with_immediate_address_argument,
    program_code: "\xCC\x34\x12",
    expected: { type: :CALL, arguments: [:Z, 0x1234] }
  },
  {
    name: :with_pointer_to_ff00_memory_area_argument,
    program_code: "\xE0\x20",
    expected: { type: :LDH, arguments: [Program::Pointer[0x20], :A] }
  },
  {
    name: :with_pointer_argument,
    program_code: "\x08\x42\x33",
    expected: { type: :LD, arguments: [Program::Pointer[0x3342], :SP] }
  },
  {
    name: :with_signed_number_argument,
    program_code: "\x18\xFE", # Two's complement of 2 = 0b00000010 is 0b11111110 = 0xFE = -2
    expected: { type: :JR, arguments: [-2] }
  },
  {
    name: :LDI_HL_A,
    program_code: "\x22",
    expected: { type: :LDI, arguments: [Program::Pointer[:HL], :A] }
  },
  {
    name: :LDI_A_HL,
    program_code: "\x2A",
    expected: { type: :LDI, arguments: [:A, Program::Pointer[:HL]] }
  },
  {
    name: :LDHL_SP_e8,
    program_code: "\xF8\xFE", # Two's complement of 2 = 0b00000010 is 0b11111110 = 0xFE = -2
    expected: { type: :LDHL, arguments: [:HL, :SP, -2] }
  },
  {
    name: :LDD_HL_A,
    program_code: "\x32",
    expected: { type: :LDD, arguments: [Program::Pointer[:HL], :A] }
  },
  {
    name: :LDD_A_HL,
    program_code: "\x3A",
    expected: { type: :LDD, arguments: [:A, Program::Pointer[:HL]] }
  },
  {
    name: :with_prefixed_opcode,
    program_code: "\xCB\x11",
    expected: { type: :RL, arguments: [:C] }
  }
].each do |test_case|
  define_method "test_program_parse_operation_type_and_arguments_#{test_case[:name]}" do |_args, assert|
    program = Program.new test_case[:program_code]

    operation = program.parse_operation(0)

    assert.equal! operation.slice(:type, :arguments),
                  test_case[:expected],
                  "Expected operation \"#{test_case[:program_code]}\" to be parsed as " \
                  "#{test_case[:expected]}, but got #{operation.slice(:type, :arguments)}"
  end
end

def test_program_parse_operation_length(_args, assert)
  ["\x00", "\x06\x42", "\x21\x42\x33"].each do |program_code|
    program = Program.new program_code

    operation = program.parse_operation(0)

    assert.equal! operation[:length],
                  program_code.length,
                  "Expected operation \"#{program_code}\" to have length #{program_code.length}, " \
                  "but got #{operation[:length]}"
  end
end
