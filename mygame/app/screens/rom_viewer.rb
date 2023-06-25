module Screens
  class RomViewer
    def initialize(args, rom)
      args.state.rom_viewer = args.state.new_entity(:rom_viewer) do |state|
        state.rom = rom
        state.program = Program.new $gtk.read_file("roms/#{rom}")
        state.address = 0x200
      end
    end

    def tick(args)
      @state = args.state.rom_viewer

      render(args)
    end

    private

    def render(args)
      y = 720
      address = @state.address
      while y.positive?
        operation = @state.program.parse_operation(address)
        argument_strings = operation[:arguments].map { |argument|
          case argument
          when Program::Pointer
            pointer_address = argument.address
            pointer_address = format_hex_value(pointer_address, byte_count: operation[:length] - 1) if pointer_address.is_a? Integer
            "[#{pointer_address}]"
          when Integer
            case operation[:type]
            when :JR
              argument.to_s
            else
              format_hex_value(argument, byte_count: operation[:length] - 1)
            end
          else
            argument.to_s
          end
        }
        args.outputs.primitives << {
          x: 10, y: y, text: "#{operation[:type]} #{argument_strings.join(', ')}"
        }
        address += operation[:length]
        y -= 20
      end
    end

    def format_hex_value(value, byte_count:)
      "$%0#{byte_count * 2}X" % value
    end
  end
end
