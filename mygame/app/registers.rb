class Registers
  def initialize
    @a = 0
    @b = 0
    @c = 0
    @d = 0
    @e = 0
    @flag_z = 0
    @flag_n = 0
    @flag_h = 0
    @flag_c = 0
    @h = 0
    @l = 0
    @sp = 0
    @pc = 0
  end

  attr_accessor :a, :b, :c, :d, :e, :h, :l, :sp, :pc, :flag_z, :flag_n, :flag_h, :flag_c

  def f
    (@flag_z << 7) | (@flag_n << 6) | (@flag_h << 5) | (@flag_c << 4)
  end

  def f=(value)
    @flag_z = (value & 0b10000000) >> 7
    @flag_n = (value & 0b01000000) >> 6
    @flag_h = (value & 0b00100000) >> 5
    @flag_c = (value & 0b00010000) >> 4
  end

  def af
    (@a << 8) | f
  end

  def af=(value)
    @a = value >> 8
    self.f = value & 0xFF
  end

  def bc
    (@b << 8) | @c
  end

  def bc=(value)
    @b = value >> 8
    @c = value & 0xFF
  end

  def de
    (@d << 8) | @e
  end

  def de=(value)
    @d = value >> 8
    @e = value & 0xFF
  end

  def hl
    (@h << 8) | @l
  end

  def hl=(value)
    @h = value >> 8
    @l = value & 0xFF
  end
end
