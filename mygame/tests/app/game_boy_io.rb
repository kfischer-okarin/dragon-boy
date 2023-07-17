require 'tests/test_helper.rb'

def test_io_remember_set_values(_args, assert)
  io = GameBoyIO.new

  0xFF00.upto(0xFF7F).each do |address|
    io[address] = 0xAA

    assert.equal! io[address], 0xAA, "Expected #{address} to be 0xAA"
  end
end

def test_io_cannot_write_to_unrelated_addresses(_args, assert)
  io = GameBoyIO.new

  assert.exception_raised! do
    io[0x8000] = 0xAA
  end
end

def test_io_turn_on_sound(_args, assert)
  io = GameBoyIO.new

  io[0xFF26] = 0b10000000

  assert.true! io.sound[:enabled]

  io[0xFF26] = 0b00000000

  assert.false! io.sound[:enabled]
end

def test_io_sound_channel1_duty_cycle(_args, assert)
  io = GameBoyIO.new

  [
    { address: 0xFF11, channel: :sound_channel1 },
    { address: 0xFF16, channel: :sound_channel2 }
  ].each do |channel|
    [
      { bit76: 0b00, duty_cycle: 0.125 },
      { bit76: 0b01, duty_cycle: 0.25 },
      { bit76: 0b10, duty_cycle: 0.5 },
      { bit76: 0b11, duty_cycle: 0.75 }
    ].each do |test_case|
      address = channel[:address]
      sound_channel = io.send(channel[:channel])

      register_value = test_case[:bit76] << 6

      io[address] = register_value

      assert.equal! sound_channel[:duty_cycle],
                    test_case[:duty_cycle],
                    "Expected duty cycle of #{channel[:channel]} to be #{test_case[:duty_cycle]}" \
                    'for register value %04X = %#0.8b' % [address, register_value]
    end
  end
end

def test_io_sound_channel1_frequency(_args, assert)
  io = GameBoyIO.new

  [
    { address: 0xFF13, channel: :sound_channel1 },
    { address: 0xFF18, channel: :sound_channel2 }
  ].each do |channel|
    address = channel[:address]
    sound_channel = io.send(channel[:channel])

    io[address] = 0b10000011
    io[address + 1] = 0b10000111

    expected_frequency = 131_072 / (2048 - 0b11110000011)
    assert.equal! sound_channel[:frequency], expected_frequency
  end
end

def test_io_sound_channel_length_timer(_args, assert)
  io = GameBoyIO.new

  [
    { address: 0xFF11, channel: :sound_channel1 },
    { address: 0xFF16, channel: :sound_channel2 }
  ].each do |channel|
    address = channel[:address]
    sound_channel = io.send(channel[:channel])

    io[address] = 0b00000000

    assert.equal! sound_channel[:length_timer],
                  64,
                  "Expected length timer of #{channel[:channel]} to be 64 for " \
                  'register value %04X = 0b00000000' % address

    io[address] = 0b00111111

    assert.equal! sound_channel[:length_timer],
                  1,
                  "Expected length timer of #{channel[:channel]} to be 1 for " \
                  'register value %02X = 0b00111111' % address
  end
end

def test_io_sound_channel_volume(_args, assert)
  io = GameBoyIO.new

  [
    { address: 0xFF12, channel: :sound_channel1 },
    { address: 0xFF17, channel: :sound_channel2 },
    { address: 0xFF21, channel: :sound_channel4 }
  ].each do |channel|
    [
      { bit8765: 0b0000, volume: 0.0 },
      { bit8765: 0b1111, volume: 1.0 },
      { bit8765: 0b0111, volume: 7.0 / 15.0 }
    ].each do |test_case|
      register_value = test_case[:bit8765] << 4

      io[channel[:address]] = register_value

      sound_channel = io.send(channel[:channel])
      assert.equal! sound_channel[:volume],
                    test_case[:volume],
                    "Expected volume to be #{test_case[:volume]} " \
                    'for register value %04X = %#0.8b' % [channel[:address], register_value]
    end
  end
end

def test_io_sound_channel_envelope_direction(_args, assert)
  io = GameBoyIO.new

  [
    { address: 0xFF12, channel: :sound_channel1 },
    { address: 0xFF17, channel: :sound_channel2 },
    { address: 0xFF21, channel: :sound_channel4 }
  ].each do |channel|
    [
      { bit3: 0, value: -1 },
      { bit3: 1, value: 1 }
    ].each do |test_case|
      register_value = test_case[:bit3] << 3

      io[channel[:address]] = register_value

      sound_channel = io.send(channel[:channel])
      assert.equal! sound_channel[:envelope_direction],
                    test_case[:value],
                    "Expected envelope direction to be #{test_case[:value]} " \
                    'for register value %04X = %#0.8b' % [channel[:address], register_value]
    end
  end
end

def test_io_sound_channel_envelope_sweep_timer(_args, assert)
  io = GameBoyIO.new

  [
    { address: 0xFF12, channel: :sound_channel1 },
    { address: 0xFF17, channel: :sound_channel2 },
    { address: 0xFF21, channel: :sound_channel4 }
  ].each do |channel|
    [
      { bit210: 0b111, value: 7 },
      { bit210: 0b000, value: 0 },
      { bit210: 0b010, value: 2 }
    ].each do |test_case|
      register_value = test_case[:bit210]

      io[channel[:address]] = register_value

      sound_channel = io.send(channel[:channel])
      assert.equal! sound_channel[:envelope_sweep_timer],
                    test_case[:value],
                    "Expected sweep timer to be #{test_case[:value]} " \
                    'for register value %04X = %#0.8b' % [channel[:address], register_value]
    end
  end
end

def test_io_sound_channel_panning(_args, assert)
  io = GameBoyIO.new

  io[0xFF25] = 0b10100110

  assert.equal! io.sound_channel1[:panning], :off, 'Expected sound channel 1 panning to be :off'
  assert.equal! io.sound_channel2[:panning], :center, 'Expected sound channel 2 panning to be :center'
  assert.equal! io.sound_channel3[:panning], :right, 'Expected sound channel 3 panning to be :right'
  assert.equal! io.sound_channel4[:panning], :left, 'Expected sound channel 4 panning to be :left'
end

def test_io_sound_master_volume(_args, assert)
  io = GameBoyIO.new

  io[0xFF24] = 0b01110000

  assert.equal! io.sound[:volume_left], 1.0
  assert.equal! io.sound[:volume_right], 0.125

  io[0xFF24] = 0b01100010

  assert.equal! io.sound[:volume_left], 0.875
  assert.equal! io.sound[:volume_right], 0.375
end

def test_io_lcd(_args, assert)
  io = GameBoyIO.new

  io[0xFF40] = 0b11111111

  assert.equal! io.lcd, {
    on: true,
    window_tilemap: 1,
    window_enabled: true,
    bg_window_tiles_start_address: 0x8000,
    bg_tilemap: 1,
    sprite_height: 16,
    sprites_enabled: true,
    bg_enabled: true
  }

  io[0xFF40] = 0b00000000

  assert.equal! io.lcd, {
    on: false,
    window_tilemap: 0,
    window_enabled: false,
    bg_window_tiles_start_address: 0x8800,
    bg_tilemap: 0,
    sprite_height: 8,
    sprites_enabled: false,
    bg_enabled: false
  }
end
