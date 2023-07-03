class GameBoyIO
  def initialize
    @values = {}
    @sound_on = nil
  end

  def [](address)
    @values[address]
  end

  def []=(address, value)
    case address
    when 0xFF26
      @sound_on = value & 0b10000000 != 0
    end
    @values[address] = value
  end

  def sound_on?
    raise 'Sound status uninitialized' if @sound_on.nil?

    @sound_on
  end
end
