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
    # def b
    # def c
    # def d
    # def e
    # def f
    # def h
    # def l
    %i[a b c d e f h l].each do |register|
      eval <<-RUBY
        def #{register}
          @values[:#{register}]
        end
      RUBY
    end

    # def a=(value)
    # def b=(value)
    # def c=(value)
    # def d=(value)
    # def e=(value)
    # def h=(value)
    # def l=(value)
    %i[a b c d e h l].each do |register|
      eval <<-RUBY
        def #{register}=(value)
          @values[:#{register}] = value
        end
      RUBY
    end

    def f=(value)
      # Delete the lower 4 bits
      @values[:f] = value & 0b11110000
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
          self.#{register1} = (value >> 8) & 0xFF
          self.#{register2} = value & 0xFF
        end
      RUBY
    end
  end
end
