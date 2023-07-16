require 'tests/assertions.rb'

def build_cpu(registers: nil, memory: nil)
  CPU.new registers: registers || Registers.new, memory: memory || Memory.new
end

def build_clock(cpu: nil, lcd: nil)
  Clock.new cpu: cpu || build_cpu, lcd: lcd || build_lcd
end

def build_lcd
  LCD.new
end

def listen_for_method_calls(object, methods)
  calls = []
  methods.each do |method|
    object.define_singleton_method method do
      calls << method
    end
  end
  calls
end
