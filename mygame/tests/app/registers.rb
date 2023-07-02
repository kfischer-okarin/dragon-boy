[:a, :b, :c, :d, :e, :h, :l].each do |register|
  define_method "test_registers_8bit_register_#{register}" do |_args, assert|
    registers = Registers.new

    registers.send "#{register}=", 0x12

    assert.equal! registers.send(register), 0x12
  end
end

def test_registers_8bit_register_f(_args, assert)
  registers = Registers.new

  registers.f = 0b10101010

  assert.equal! registers.f, 0b10100000
end

def test_registers_16bit_register_af(_args, assert)
  register = Registers.new

  register.a = 0x12
  register.f = 0x34

  assert.equal! register.af, 0x1230

  register.af = 0x5678

  assert.equal! register.a, 0x56
  assert.equal! register.f, 0x70
end

def test_registers_16bit_register_bc(_args, assert)
  register = Registers.new

  register.b = 0x12
  register.c = 0x34

  assert.equal! register.bc, 0x1234

  register.bc = 0x5678

  assert.equal! register.b, 0x56
  assert.equal! register.c, 0x78
end

def test_registers_16bit_register_de(_args, assert)
  register = Registers.new

  register.d = 0x12
  register.e = 0x34

  assert.equal! register.de, 0x1234

  register.de = 0x5678

  assert.equal! register.d, 0x56
  assert.equal! register.e, 0x78
end

def test_registers_16bit_register_hl(_args, assert)
  register = Registers.new

  register.h = 0x12
  register.l = 0x34

  assert.equal! register.hl, 0x1234

  register.hl = 0x5678

  assert.equal! register.h, 0x56
  assert.equal! register.l, 0x78
end

[:sp, :pc].each do |register|
  define_method "test_registers_16bit_register_#{register}" do |_args, assert|
    registers = Registers.new

    registers.send "#{register}=", 0x1234

    assert.equal! registers.send(register), 0x1234
  end
end

def test_registers_flag_z(_args, assert)
  registers = Registers.new

  registers.f = 0b00000000

  assert.equal! registers.flag_z, 0

  registers.flag_z = 1

  assert.equal! registers.f, 0b10000000
end

def test_registers_flag_n(_args, assert)
  registers = Registers.new

  registers.f = 0b00000000

  assert.equal! registers.flag_n, 0

  registers.flag_n = 1

  assert.equal! registers.f, 0b01000000
end

def test_registers_flag_h(_args, assert)
  registers = Registers.new

  registers.f = 0b00000000

  assert.equal! registers.flag_h, 0

  registers.flag_h = 1

  assert.equal! registers.f, 0b00100000
end

def test_registers_flag_c(_args, assert)
  registers = Registers.new

  registers.f = 0b00000000

  assert.equal! registers.flag_c, 0

  registers.flag_c = 1

  assert.equal! registers.f, 0b00010000
end

def test_registers_flags(_args, assert)
  registers = Registers.new
  registers.flag_z = 1
  registers.flag_n = 0
  registers.flag_h = 1
  registers.flag_c = 0

  assert.equal! registers.flags, { z: 1, n: 0, h: 1, c: 0 }
end

def test_registers_flags=(_args, assert)
  registers = Registers.new
  registers.flag_z = 0
  registers.flag_n = 1
  registers.flag_h = 0
  registers.flag_c = 1

  registers.flags = { z: 1, n: 0, h: 1, c: 0 }

  assert.equal! registers.flag_z, 1
  assert.equal! registers.flag_n, 0
  assert.equal! registers.flag_h, 1
  assert.equal! registers.flag_c, 0
end

def test_registers_to_h(_args, assert)
  registers = Registers.new

  registers.a = 0x12
  registers.f = 0b10100000
  registers.b = 0x56
  registers.c = 0x78
  registers.d = 0x9a
  registers.e = 0xbc
  registers.h = 0xde
  registers.l = 0xf0
  registers.sp = 0x1234
  registers.pc = 0x5678

  assert.equal! registers.to_h, {
    a: 0x12,
    f: 0b10100000,
    b: 0x56,
    c: 0x78,
    d: 0x9a,
    e: 0xbc,
    h: 0xde,
    l: 0xf0,
    sp: 0x1234,
    pc: 0x5678
  }
end
