class Program
  Pointer = Struct.new(:address) do
    def self.[](address)
      new address
    end
  end

  def self.opcodes
    unless @opcodes
      opcodes_json = $gtk.parse_json_file('app/opcodes.json')

      @opcodes = {}
      %w[unprefixed cbprefixed].each do |type|
        result = []
        opcodes_json[type].each do |opcode, definition|
          opcode_as_number = opcode.to_i(16)
          result[opcode_as_number] = {
            type: definition['mnemonic'].to_sym,
            arguments: definition['operands'].map { |operand|
              if operand['immediate']
                operand['name'].to_sym
              else
                Pointer[operand['name'].to_sym]
              end
            }
          }
        end
        @opcodes[type.to_sym] = result
      end

      # Set special types for the load instructions that increment/decrement their pointers
      # so they can be distinguished just by their type
      @opcodes[:unprefixed][0x22][:type] = :LDI
      @opcodes[:unprefixed][0x2A][:type] = :LDI
      @opcodes[:unprefixed][0x32][:type] = :LDD
      @opcodes[:unprefixed][0x3A][:type] = :LDD
      @opcodes[:unprefixed][0xF8][:type] = :LDHL
    end

    @opcodes
  end

  def initialize(assembled_code)
    @code_bytes = assembled_code.chars.map(&:ord)
  end

  def parse_operation(address)
    opcode = @code_bytes[address]

    if opcode == 0xCB # CB-prefixed opcode
      opcode = @code_bytes[address + 1]
      argument_offset = 2
      operation_definition = Program.opcodes[:cbprefixed][opcode]
    else
      argument_offset = 1
      operation_definition = Program.opcodes[:unprefixed][opcode]
    end

    arguments = operation_definition[:arguments].map { |argument|
      case argument
      when :n8
        value = @code_bytes[address + argument_offset]
        argument_offset += 1
        value
      when :n16, Pointer[:a16]
        # Little endian according to https://gbdev.io/gb-opcodes/optables/
        value = @code_bytes[address + argument_offset] + (@code_bytes[address + argument_offset + 1] << 8)
        value = Pointer[value] if argument == Pointer[:a16]
        argument_offset += 2
        value
      when :e8
        value = @code_bytes[address + argument_offset]
        argument_offset += 1
        value -= 0x100 if value > 0x7F # Two's complement
        value
      else
        argument
      end
    }

    {
      type: operation_definition[:type],
      arguments: arguments
    }
  end
end
