require 'tests/test_helper.rb'

def test_io_remember_set_values(_args, assert)
  io = GameBoyIO.new

  (0xFF00..0xFF7F).each do |address|
    io[address] = 0xAA

    assert.equal! io[address], 0xAA, "Expected #{address} to be 0xAA"
  end
end

def test_io_turn_on_sound(_args, assert)
  io = GameBoyIO.new

  assert.exception_raised! 'Expected exception to be raised when trying to access sound status uninitialized' do
    io.sound_on?
  end

  io[0xFF26] = 0b10000000

  assert.true! io.sound_on?

  io[0xFF26] = 0b00000000

  assert.false! io.sound_on?
end

def test_io_sound_channel1_duty_cycle(_args, assert)
  io = GameBoyIO.new

  [
    { bit76: 0b00, duty_cycle: 0.125 },
    { bit76: 0b01, duty_cycle: 0.25 },
    { bit76: 0b10, duty_cycle: 0.5 },
    { bit76: 0b11, duty_cycle: 0.75 }
  ].each do |test_case|
    register_value = test_case[:bit76] << 6

    io[0xFF11] = register_value

    assert.equal! io.sound_channel1[:duty_cycle],
                  test_case[:duty_cycle],
                  "Expected duty cycle to be #{test_case[:duty_cycle]} for 0b#{register_value.to_s(2)}"
  end
end

def test_io_sound_channel1_length_timer(_args, assert)
  io = GameBoyIO.new

  io[0xFF11] = 0b00000000

  assert.equal! io.sound_channel1[:length_timer], 64

  io[0xFF11] = 0b00111111

  assert.equal! io.sound_channel1[:length_timer], 1
end

def test_io_sound_channel1_volume(_args, assert)
  io = GameBoyIO.new

  [
    { bit8765: 0b0000, volume: 0.0 },
    { bit8765: 0b1111, volume: 1.0 },
    { bit8765: 0b0111, volume: 7.0 / 15.0 }
  ].each do |test_case|
    register_value = test_case[:bit8765] << 4

    io[0xFF12] = register_value

    assert.equal! io.sound_channel1[:volume],
                  test_case[:volume],
                  "Expected volume to be #{test_case[:volume]} for 0b#{register_value.to_s(2)}"
  end
end
