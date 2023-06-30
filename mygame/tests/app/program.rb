def test_program_element_reference(_args, assert)
  program = Program.new "\x00\x06\x42"

  assert.equal! program[0], 0x00
  assert.equal! program[1], 0x06
end

def test_program_length(_args, assert)
  program = Program.new "\x00\x06\x42"

  assert.equal! program.length, 3
end
