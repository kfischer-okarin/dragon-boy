class Registers
  def initialize
    @a = 0
    @b = 0
    @c = 0
    @d = 0
    @e = 0
    @f = 0
    @h = 0
    @l = 0
    @sp = 0
    @pc = 0
  end

  attr_accessor :a, :b, :c, :d, :e, :h, :l, :sp, :pc

  attr_reader :f

  def f=(value)
    @f = value & 0b11110000
  end

  def af
    (@a << 8) | @f
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
