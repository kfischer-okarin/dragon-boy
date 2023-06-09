def test_cpu_registers_single_registers_except_f(_args, assert)
  %i[a b c d e h l].each do |register|
    registers = CPU::Registers.new
    registers.send :"#{register}=", 0b11001100

    assert.binary_equal! registers.send(register), 0b11001100
  end
end

def test_cpu_registers_lower_4_bits_of_f_should_always_be_0(_args, assert)
  registers = CPU::Registers.new
  registers.f = 0b11001100

  assert.binary_equal! registers.f, 0b11000000
end

def test_cpu_registers_zero_flag(_args, assert)
  registers = CPU::Registers.new
  registers.f = 0b10000000

  assert.equal! registers.zero, 1

  registers.zero = 0

  assert.binary_equal! registers.f, 0b00000000
end

def test_cpu_registers_subtract_flag(_args, assert)
  registers = CPU::Registers.new
  registers.f = 0b01000000

  assert.equal! registers.subtract, 1

  registers.subtract = 0

  assert.binary_equal! registers.f, 0b00000000
end

def test_cpu_registers_half_carry_flag(_args, assert)
  registers = CPU::Registers.new
  registers.f = 0b00100000

  assert.equal! registers.half_carry, 1

  registers.half_carry = 0

  assert.binary_equal! registers.f, 0b00000000
end

def test_cpu_registers_carry_flag(_args, assert)
  registers = CPU::Registers.new
  registers.f = 0b00010000

  assert.equal! registers.carry, 1

  registers.carry = 0

  assert.binary_equal! registers.f, 0b00000000
end

def test_cpu_registers_single_registers_are_zero_by_default(_args, assert)
  %i[a b c d e f h l].each do |register|
    registers = CPU::Registers.new

    assert.binary_equal! registers.send(register), 0
  end
end

def test_cpu_registers_get_double_registers(_args, assert)
  [
    %i[a f af],
    %i[b c bc],
    %i[d e de],
    %i[h l hl]
  ].each do |register1, register2, double_register|
    registers = CPU::Registers.new
    registers.send :"#{register1}=", 0b11001100
    registers.send :"#{register2}=", 0b11110000

    assert.binary_equal! registers.send(double_register), 0b1100110011110000
  end
end

def test_cpu_registers_set_double_registers(_args, assert)
  [
    %i[a f af],
    %i[b c bc],
    %i[d e de],
    %i[h l hl]
  ].each do |register1, register2, double_register|
    registers = CPU::Registers.new
    registers.send :"#{double_register}=", 0b1100110011110000

    assert.binary_equal! registers.send(register1), 0b11001100
    assert.binary_equal! registers.send(register2), 0b11110000
  end
end

module GTK
  class Assert
    def binary_equal!(value, expected)
      equal! value, expected, "Expected 0b#{value.to_s(2)}\n   to be 0b#{expected.to_s(2)}"
    end
  end
end
