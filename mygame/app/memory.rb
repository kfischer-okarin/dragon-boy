class Memory
  def initialize
    @rom = nil
    @boot_rom = nil
    @content = Array.new(length)
    @content.fill 0xFF, 0, 0x8000
    @io = nil
    @vram = nil
    @lcd
  end

  def load_rom(rom)
    @rom = rom.bytes
    @content[0x0000...@rom.length] = @rom.dup
  end

  def load_boot_rom(boot_rom)
    @boot_rom = boot_rom.bytes
    @content[0x0000..0x00FF] = @boot_rom
  end

  def connect_io(io)
    @io = io
  end

  def connect_vram(vram)
    @vram = vram
  end

  def connect_lcd(lcd)
    @lcd = lcd
  end

  def [](address)
    memory_target(address)[address]
  end

  def []=(address, value)
    memory_target(address)[address] = value
  end

  def length
    65_536
  end

  def to_a
    @content.dup
  end

  private

  def memory_target(address)
    case address
    when 0xFF47, 0x8000..0x9FFF
      @vram || @content
    when 0xFF42..0xFF44
      @lcd || @content
    when 0xFF00..0xFF7F
      @io || @content
    else
      @content
    end
  end
end
