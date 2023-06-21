class Program
  def initialize(assembled_code)
    @assembled_code = assembled_code
  end

  def parse_operation(address)
    { type: :nop, arguments: [], length: 1 }
  end
end
