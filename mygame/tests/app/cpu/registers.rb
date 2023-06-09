def test_cpu_registers_single_registers(_args, assert)
  %i[a b c d e f h l].each do |register|
    registers = CPU::Registers.new
    registers.send :"#{register}=", 0b11001100

    assert.equal! registers.send(register), 0b11001100
  end
end

def test_cpu_registers_single_registers_are_zero_by_default(_args, assert)
  %i[a b c d e f h l].each do |register|
    registers = CPU::Registers.new

    assert.equal! registers.send(register), 0
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

    assert.equal! registers.send(double_register), 0b1100110011110000
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

    assert.equal! registers.send(register1), 0b11001100
    assert.equal! registers.send(register2), 0b11110000
  end
end
