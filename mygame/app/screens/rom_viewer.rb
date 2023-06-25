module Screens
  class RomViewer
    def initialize(args, rom)
      args.state.rom_viewer = args.state.new_entity(:rom_viewer) do |state|
        state.rom = rom
        state.program = Program.new $gtk.read_file("roms/#{rom}")
        state.address = 0x100
      end
    end

    def tick(args)
      @state = args.state.rom_viewer

      render(args)
    end

    private

    def render(args)
      render_title_bar(args)
      render_program(args, x: 0, top: 680)
      render_bytes(args, x: 640, top: 680)
    end

    def render_title_bar(args)
      args.outputs.primitives << {
        x: 640, y: 720, text: @state.rom, size_enum: 3, alignment_enum: 1
      }.label!
      args.outputs.primitives << { x: 0, y: 690, x2: 1280, y2: 690 }.line!
    end

    def render_program(args, x:, top:)
      y = top
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
          x: x + 10, y: y, text: '%04X' % address
        }.label!
        args.outputs.primitives << {
          x: x + 80, y: y, text: "#{operation[:type]} #{argument_strings.join(', ')}"
        }.label!
        address += operation[:length]
        break if address >= @state.program.length

        y -= 20
      end
    end

    def render_bytes(args, x:, top:)
      y = top
      address = @state.address.idiv(16) * 16
      while y.positive?
        16.times do |i|
          args.outputs.primitives << {
            x: x + 80 + i * 30 , y: y, text: '%02X' % @state.program[address + i]
          }.label!
        end
        args.outputs.primitives << {
          x: x + 10, y: y, text: '%04X' % (address & 0xFFF0)
        }.label!
        y -= 20
        address += 16
        break if address >= @state.program.length
      end
    end

    def format_hex_value(value, byte_count:)
      "$%0#{byte_count * 2}X" % value
    end
  end
end
