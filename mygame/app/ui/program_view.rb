module UI
  class ProgramView
    HOVER_COLOR = { r: 255, g: 255, b: 0 }.freeze
    JUMP_TARGET_COLOR = { r: 255, g: 128, b: 0 }.freeze

    attr_accessor :bytes, :x, :y, :w, :h, :offset, :highlights, :breakpoints, :comments

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
      @breakpoints = {}
      @comments = {}
    end

    def update(args)
      reset_highlights
      calc_rendered_operations
      handle_hover(args)
      handle_toggle_breakpoint(args)
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      render_highlights(gtk_outputs)
      render_operations(gtk_outputs)
    end

    def address_visible?(address)
      address >= @offset && address <= maximum_visible_address
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

        rendered_operation = {
          rect: { x: @x + 10, y: y - 20, w: @w - 20, h: 20 },
          address: address,
          text: "#{operation[:type]} #{argument_strings.join(', ')}",
          comment: @comments[address],
          operation: operation,
          target_address: calc_target_address(address, operation)
        }
        rendered_operation.compact!
        @rendered_operations << rendered_operation
        address += operation[:length]
        break if address >= @bytes.length

        y -= 20
      end
    end

    def calc_target_address(address, operation)
      case operation[:type]
      when :JR
        address + operation[:length] + operation[:arguments].last
      when :CALL
        operation[:arguments].last
      when :JP
        target_address = operation[:arguments].last
        target_address.is_a?(Numeric) ? target_address : nil
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
      return unless hovered_operation[:target_address]

      @highlights << {
        address: hovered_operation[:target_address],
        color: JUMP_TARGET_COLOR
      }
    end

    def handle_toggle_breakpoint(args)
      return unless args.inputs.mouse.click && @hovered_operation

      address = @hovered_operation[:address]
      if @breakpoints.key? address
        @breakpoints.delete address
      else
        @breakpoints[address] = true
      end
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
        address = rendered_operation[:address]
        operation_primitives = [
          {
            x: x, y: y, text: '%04X' % address,
            r: 100, g: 100, b: 100
          }.label!,
          {
            x: x + 80, y: y, text: rendered_operation[:text]
          }.label!
        ]
        if rendered_operation[:comment]
          operation_primitives << {
            x: x + 250, y: y, text: rendered_operation[:comment],
            r: 100, g: 100, b: 100
          }.label!
        end
        if @breakpoints.key? address
          operation_primitives << {
            x: x + 60, y: y, text: 'B', r: 255, g: 0, b: 0
          }.label!
        end
        operation_primitives
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
