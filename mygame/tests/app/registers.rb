[:a, :b, :c, :d, :e, :h, :l].each do |register|
  define_method "test_8bit_register_#{register}" do |_args, assert|
    registers = Registers.new

    registers.send "#{register}=", 0x12

    assert.equal! registers.send(register), 0x12
  end
end

def test_16bit_register_bc(_args, assert)
  register = Registers.new

  register.b = 0x12
  register.c = 0x34

  assert.equal! register.bc, 0x1234

  register.bc = 0x5678

  assert.equal! register.b, 0x56
  assert.equal! register.c, 0x78
end

def test_16bit_register_de(_args, assert)
  register = Registers.new

  register.d = 0x12
  register.e = 0x34

  assert.equal! register.de, 0x1234

  register.de = 0x5678

  assert.equal! register.d, 0x56
  assert.equal! register.e, 0x78
end

def test_16bit_register_hl(_args, assert)
  register = Registers.new

  register.h = 0x12
  register.l = 0x34

  assert.equal! register.hl, 0x1234

  register.hl = 0x5678

  assert.equal! register.h, 0x56
  assert.equal! register.l, 0x78
end
