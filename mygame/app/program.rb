class Program
  def initialize(assembled_code)
    @code_bytes = assembled_code.chars.map(&:ord)
  end

  def [](address)
    @code_bytes[address]
  end

  def length
    @code_bytes.length
  end
end
