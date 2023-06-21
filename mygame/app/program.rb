class Program
  def self.opcodes
    unless @opcodes
      opcodes_json = $gtk.parse_json_file('app/opcodes.json')

      @opcodes = {}
      %w[unprefixed cbprefixed].each do |type|
        result = []
        opcodes_json[type].each do |opcode, definition|
          opcode_as_number = opcode.to_i(16)
          result[opcode_as_number] = {
            type: definition['mnemonic'].downcase.to_sym,
            length: definition['bytes']
          }
        end
        @opcodes[type.to_sym] = result
      end
    end

    @opcodes
  end

  def initialize(assembled_code)
    @code_bytes = assembled_code.chars.map(&:ord)
  end

  def parse_operation(address)
    opcode = @code_bytes[address]
    operation = Program.opcodes[:unprefixed][opcode]
    operation.merge(arguments: [])
  end
end