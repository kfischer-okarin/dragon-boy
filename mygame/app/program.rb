class Program
  def initialize(assembled_code)
    @code_bytes = assembled_code.chars.map(&:ord)
  end

  def parse_operation(address)
    { type: :nop, arguments: [], length: 1 }
  end
end
