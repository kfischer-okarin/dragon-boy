require 'tests/assertions.rb'

def build_cpu
  CPU.new registers: Registers.new, memory: Memory.new
end
