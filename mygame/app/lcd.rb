class LCD
  attr_accessor :mode, :scanline

  def initialize
    @mode = :oam_scan
    @scanline = 0
  end

  def advance_scanline
    case @mode
    when :oam_scan
      @mode = :pixel_transfer
    when :pixel_transfer
      @mode = :hblank
    when :hblank
      @scanline += 1
      @mode = @scanline == 144 ? :vblank : :oam_scan
    when :vblank
      if @scanline == 153
        @scanline = 0
        @mode = :oam_scan
      else
        @scanline += 1
      end
    end
  end
end
