class LCD
  attr_accessor :mode

  def initialize
    @values = {}
    @mode = :oam_scan
    self.scanline = 0
  end

  def [](address)
    @values[address]
  end

  def []=(address, value)
    case address
    when 0xFF44
      # Read-only
    else
      raise 'Illegal LCD address: %04X' % address
    end
  end

  def scanline
    @values[0xFF44]
  end

  def scanline=(value)
    @values[0xFF44] = value
  end

  def advance_scanline
    case @mode
    when :oam_scan
      @mode = :pixel_transfer
    when :pixel_transfer
      @mode = :hblank
    when :hblank
      self.scanline += 1
      @mode = scanline == 144 ? :vblank : :oam_scan
    when :vblank
      if scanline == 153
        self.scanline = 0
        @mode = :oam_scan
      else
        self.scanline += 1
      end
    end
  end
end
