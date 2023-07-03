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
