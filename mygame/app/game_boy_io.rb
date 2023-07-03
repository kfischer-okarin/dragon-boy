class GameBoyIO
  def initialize
    @sound_on = nil
  end

  def []=(address, value)
    case address
    when 0xFF26
      @sound_on = value & 0b10000000 != 0
    end
  end

  def sound_on?
    raise 'Sound status uninitialized' if @sound_on.nil?

    @sound_on
  end
end
