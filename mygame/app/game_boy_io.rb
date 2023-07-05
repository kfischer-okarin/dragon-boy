class GameBoyIO
  attr_reader :sound_channel1, :sound_channel2, :sound_channel4

  def initialize
    @values = {}
    @sound_on = nil
    @sound_channel1 = {}
    @sound_channel2 = {}
    @sound_channel4 = {}
  end

  def [](address)
    @values[address]
  end

  def []=(address, value)
    case address
    when 0xFF11
      @sound_channel1[:duty_cycle] = DUTY_CYCLES[value & 0b11000000]
      # DIV-APU counter is increased at 512Hz (every 8192 CPU cycles)
      # Every two increments of the DIV-APU counter, the length timer is decreased by one
      # When the length timer reaches zero, the sound channel is disabled
      # Therefore the length timer is in units of 1/256 seconds.
      # (Length ranges from 0 - 1/4 seconds)
      @sound_channel1[:length_timer] = 64 - (value & 0b00111111)
    when 0xFF12, 0xFF17, 0xFF21
      channel = sound_channel(address)
      # Volume is in units of 1/15
      channel[:volume] = ((value & 0b11110000) >> 4) / 15.0
      channel[:envelope_direction] = (value & 0b00001000).zero? ? -1 : 1
    when 0xFF26
      @sound_on = value & 0b10000000 != 0
    end
    @values[address] = value
  end

  DUTY_CYCLES = {
    0b00000000 => 0.125,
    0b01000000 => 0.25,
    0b10000000 => 0.5,
    0b11000000 => 0.75
  }.freeze

  def sound_on?
    raise 'Sound status uninitialized' if @sound_on.nil?

    @sound_on
  end

  private

  def sound_channel(address)
    case address
    when 0xFF12
      @sound_channel1
    when 0xFF17
      @sound_channel2
    when 0xFF21
      @sound_channel4
    end
  end
end
