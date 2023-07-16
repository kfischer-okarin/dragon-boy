module Operation
  unless const_defined? :Pointer # prevent changing the class when hot-reloading this file
    Pointer = Struct.new(:address) do
      def self.[](address)
        new address
      end
    end
  end

  class << self
    def opcodes
      unless @opcodes
        opcodes_json = $gtk.parse_json_file('app/opcodes.json')

        @opcodes = {}
        %w[unprefixed cbprefixed].each do |type|
          result = []
          opcodes_json[type].each do |opcode, definition|
            opcode_as_number = opcode.to_i(16)
            cycles = definition['cycles']
            result[opcode_as_number] = {
              type: definition['mnemonic'].to_sym,
              arguments: definition['operands'].map { |operand|
                if operand['immediate']
                  if ('0'..'9').include? operand['name']
                    operand['name'].to_i
                  else
                    operand['name'].to_sym
                  end
                else
                  Pointer[operand['name'].to_sym]
                end
              },
              length: definition['bytes'],
              cycles: cycles.size == 1 ? cycles[0] : { taken: cycles[0], untaken: cycles[1] }
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

    def parse(bytes, address)
      opcode = bytes[address]

      if opcode == 0xCB # CB-prefixed opcode
        opcode = bytes[address + 1]
        argument_offset = 2
        operation_definition = opcodes[:cbprefixed][opcode]
      else
        argument_offset = 1
        operation_definition = opcodes[:unprefixed][opcode]
      end

      arguments = operation_definition[:arguments].map { |argument|
        case argument
        when :n8, Pointer[:a8]
          value = bytes[address + argument_offset]
          value = Pointer[value] if argument == Pointer[:a8]
          argument_offset += 1
          value
        when :n16, Pointer[:a16], :a16
          # Little endian according to https://gbdev.io/gb-opcodes/optables/
          value = bytes[address + argument_offset] + (bytes[address + argument_offset + 1] << 8)
          value = Pointer[value] if argument == Pointer[:a16]
          argument_offset += 2
          value
        when :e8
          value = bytes[address + argument_offset]
          argument_offset += 1
          value -= 0x100 if value > 0x7F # Two's complement
          value
        else
          argument
        end
      }

      {
        type: operation_definition[:type],
        arguments: arguments,
        opcode: opcode,
        length: operation_definition[:length],
        cycles: operation_definition[:cycles]
      }
    end
  end
end
