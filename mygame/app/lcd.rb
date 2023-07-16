class LCD
  attr_accessor :mode

  def initialize
    @values = {
      0xFF42 => 0,
      0xFF43 => 0,
    }
    @mode = :oam_scan
    self.scanline = 0
  end

  def viewport_position
    {
      x: @values[0xFF43],
      y: @values[0xFF42]
    }
  end

  def [](address)
    @values[address]
  end

  def []=(address, value)
    case address
    when 0xFF42, 0xFF43
    when 0xFF44
      return # read-only
    else
      raise 'Illegal LCD address: %04X' % address
    end
    @values[address] = value
  end

  def scanline
    @values[0xFF44]
  end

  def scanline=(value)
    @values[0xFF44] = value
  end

  def current_mode_duration
    MODE_DURATION[mode]
  end

  MODE_DURATION = {
    oam_scan: 80,
    pixel_transfer: 172,
    hblank: 204,
    vblank: 456
  }.freeze

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
