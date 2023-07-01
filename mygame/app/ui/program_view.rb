module UI
  class ProgramView
    HOVER_COLOR = { r: 255, g: 255, b: 0 }.freeze

    attr_accessor :bytes, :x, :y, :w, :h, :offset, :highlights

    attr_reader :hovered_operation

    attr_rect

    def initialize(bytes, x:, y:, w:, h:)
      @bytes = bytes
      @x = x
      @y = y
      @w = w
      @h = h
      @offset = 0
      @highlights = []
      @rendered_operations = []
    end

    def update(args)
      reset_highlights
      calc_rendered_operations
      handle_hover(args)
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      render_highlights(gtk_outputs)
      render_operations(gtk_outputs)
    end

    def maximum_visible_address
      @rendered_operations.last[:address] + @rendered_operations.last[:operation][:length] - 1
    end

    private

    def reset_highlights
      @highlights = []
    end

    def calc_rendered_operations
      @rendered_operations = []

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

        @rendered_operations << {
          rect: { x: @x + 10, y: y - 20, w: @w - 20, h: 20 },
          address: address,
          text: "#{operation[:type]} #{argument_strings.join(', ')}",
          operation: operation
        }
        address += operation[:length]
        break if address >= @bytes.length

        y -= 20
      end
    end

    def handle_hover(args)
      @hovered_operation = @rendered_operations.find { |rendered_operation|
        args.inputs.mouse.inside_rect? rendered_operation[:rect]
      }
      return unless @hovered_operation

      @highlights << {
        address: hovered_operation[:address],
        color: HOVER_COLOR
      }
    end

    def render_highlights(gtk_outputs)
      gtk_outputs.primitives << @highlights.map { |highlight|
        next unless highlight[:address] >= @offset && highlight[:address] <= maximum_visible_address

        rendered_operation = @rendered_operations.find { |rendered|
          rendered[:address] == highlight[:address]
        }
        next unless rendered_operation

        gtk_outputs.primitives << rendered_operation[:rect].merge(path: :pixel).sprite!(highlight[:color])
      }
    end

    def render_operations(gtk_outputs)
      gtk_outputs.primitives << @rendered_operations.map { |rendered_operation|
        x = rendered_operation[:rect][:x]
        y = rendered_operation[:rect][:y] + 20
        [
          {
            x: x, y: y, text: '%04X' % rendered_operation[:address],
            r: 100, g: 100, b: 100
          }.label!,
          {
            x: x + 80, y: y, text: rendered_operation[:text]
          }.label!
        ]
      }
    end

    def format_hex_value(value, byte_count:)
      "$%0#{byte_count * 2}X" % value
    end

    def vertical_padding
      15
    end
  end
end
