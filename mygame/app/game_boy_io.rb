class GameBoyIO
  attr_reader :palettes, :sound, :sound_channel1, :sound_channel2, :sound_channel3, :sound_channel4

  def initialize
    @values = {}
    @palettes = {}
    @sound = {}
    @sound_channel1 = {}
    @sound_channel2 = {}
    @sound_channel3 = {}
    @sound_channel4 = {}
  end

  def [](address)
    @values[address]
  end

  def []=(address, value)
    case address
    when 0xFF11, 0xFF16
      channel = sound_channel(address)
      channel[:duty_cycle] = DUTY_CYCLES[value & 0b11000000]
      # DIV-APU counter is increased at 512Hz (every 8192 CPU cycles)
      # Every two increments of the DIV-APU counter (i.e. every 1/256 s),
      # the length timer is decreased by one.
      # When the length timer reaches zero, the sound channel is disabled
      # Thus the effective length ranges from 0 - 1/4 seconds.
      channel[:length_timer] = 64 - (value & 0b00111111)
    when 0xFF12, 0xFF17, 0xFF21
      channel = sound_channel(address)
      # Volume is in units of 1/15
      channel[:volume] = ((value & 0b11110000) >> 4) / 15.0
      channel[:envelope_direction] = (value & 0b00001000).zero? ? -1 : 1
      # DIV-APU counter is increased at 512Hz (every 8192 CPU cycles)
      # Every 8 increments of the DIV-APU counter (every 1/64 second),
      # the timer is decreased by one.
      # Thus the effective sweep period ranges from 1/64 to 7/64 seconds.
      # When it reaches zero, volume is increased/decreased by one to
      # a minimum of 0 and a maximum of 15.
      # Even if the volume reaches 0, the channel is not disabled.
      # A timer value of 0 disables the envelope.
      channel[:envelope_sweep_timer] = value & 0b00000111
    when 0xFF24
      # Bit 7 and 3 are for VIN panning (not implemented)

      # Volume is in units of 1/8. Range is 1/8 to 1.
      @sound[:volume_left] = (((value & 0b01110000) >> 4) + 1) / 8.0
      @sound[:volume_right] = ((value & 0b00000111) + 1) / 8.0
    when 0xFF25
      @sound_channel1[:panning] = panning(value, 0b00010000, 0b00000001)
      @sound_channel2[:panning] = panning(value, 0b00100000, 0b00000010)
      @sound_channel3[:panning] = panning(value, 0b01000000, 0b00000100)
      @sound_channel4[:panning] = panning(value, 0b10000000, 0b00001000)
    when 0xFF26
      @sound[:enabled] = value & 0b10000000 != 0
    when 0xFF00..0xFF7F
      # Not yet implemented
    else
      raise 'Illegal IO address: %04X' % address
    end
    @values[address] = value
  end

  DUTY_CYCLES = {
    0b00000000 => 0.125,
    0b01000000 => 0.25,
    0b10000000 => 0.5,
    0b11000000 => 0.75
  }.freeze

  private

  def sound_channel(address)
    case address
    when 0xFF11, 0xFF12
      @sound_channel1
    when 0xFF16, 0xFF17
      @sound_channel2
    when 0xFF21
      @sound_channel4
    end
  end

  def panning(value, left_mask, right_mask)
    case value & (left_mask | right_mask)
    when left_mask
      :left
    when right_mask
      :right
    when 0
      :off
    else
      :center
    end
  end
end
