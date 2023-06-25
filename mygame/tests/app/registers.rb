[:a, :b, :c, :d, :e, :h, :l].each do |register|
  define_method "test_8bit_register_#{register}" do |_args, assert|
    registers = Registers.new

    registers.send "#{register}=", 0x12

    assert.equal! registers.send(register), 0x12
  end
end
