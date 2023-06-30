module UI
  class ProgramView
    attr_accessor :bytes, :x, :y, :w, :h, :offset

    attr_rect

    def initialize(bytes, x:, y:, w:, h:)
      @bytes = bytes
      @x = x
      @y = y
      @w = w
      @h = h
      @offset = 0
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      render_operations(gtk_outputs)
    end

    private

    def render_operations(gtk_outputs)
      y = top - vertical_padding
      address = @offset
      while y > @y + vertical_padding
        operation = Operation.parse(@bytes, address)
        argument_strings = operation[:arguments].map { |argument|
          case argument
          when Operation::Pointer
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
        gtk_outputs.primitives << {
          x: x + 10, y: y, text: '%04X' % address,
          r: 100, g: 100, b: 100
        }.label!
        gtk_outputs.primitives << {
          x: x + 80, y: y, text: "#{operation[:type]} #{argument_strings.join(', ')}"
        }.label!
        address += operation[:length]
        break if address >= @bytes.length

        y -= 20
      end
    end

    def format_hex_value(value, byte_count:)
      "$%0#{byte_count * 2}X" % value
    end

    def vertical_padding
      15
    end
  end
end
