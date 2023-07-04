class GameBoyIO
  attr_reader :sound_channel1

  def initialize
    @values = {}
    @sound_on = nil
    @sound_channel1 = {}
  end

  def [](address)
    @values[address]
  end

  def []=(address, value)
    case address
    when 0xFF11
      @sound_channel1[:duty_cycle] = DUTY_CYCLES[value & 0b11000000]
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
end
