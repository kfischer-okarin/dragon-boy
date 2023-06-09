module CPU
  class Registers
    def initialize
      @values = {
        a: 0,
        b: 0,
        c: 0,
        d: 0,
        e: 0,
        f: 0,
        h: 0,
        l: 0
      }
    end

    # def a
    # def a=(value)
    # def b
    # def b=(value)
    # def c
    # def c=(value)
    # def d
    # def d=(value)
    # def e
    # def e=(value)
    # def f
    # def f=(value)
    # def h
    # def h=(value)
    # def l
    # def l=(value)
    %i[a b c d e f h l].each do |register|
      eval <<-RUBY
        def #{register}
          @values[:#{register}]
        end

        def #{register}=(value)
          @values[:#{register}] = value
        end
      RUBY
    end

    # def af
    # def af=(value)
    # def bc
    # def bc=(value)
    # def de
    # def de=(value)
    # def hl
    # def hl=(value)
    [
      %i[a f],
      %i[b c],
      %i[d e],
      %i[h l]
    ].each do |register1, register2|
      eval <<-RUBY
        def #{register1}#{register2}
          (@values[:#{register1}] << 8) | @values[:#{register2}]
        end

        def #{register1}#{register2}=(value)
          @values[:#{register1}] = (value >> 8) & 0xFF
          @values[:#{register2}] = value & 0xFF
        end
      RUBY
    end
  end
end
