module UI
  class ProgramView
    HOVER_COLOR = { r: 255, g: 255, b: 0 }.freeze
    JUMP_TARGET_COLOR = { r: 255, g: 128, b: 0 }.freeze

    attr_accessor :bytes, :x, :y, :w, :h, :offset, :highlights, :breakpoints, :comments

    attr_reader :hovered_line, :memory_areas

    attr_rect

    def initialize(bytes, x:, y:, w:, h:)
      @bytes = bytes
      @x = x
      @y = y
      @w = w
      @h = h
      @offset = 0
      @highlights = []
      @rendered_lines = []
      @breakpoints = {}
      @comments = {}
      @memory_areas = {}
      @lines = {}
      @parsed_up_to = -1
    end

    def memory_areas=(value)
      lowest_memory_area_address = value.keys.min
      @lines.delete_if { |address, _| address >= lowest_memory_area_address }
      @parsed_up_to = @lines.keys.max || -1
      @memory_areas = value
    end

    def update(args)
      reset_highlights
      calc_rendered_lines
      handle_hover(args)
      click_handled = handle_scroll(args)
      handle_toggle_breakpoint(args) unless click_handled
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      render_highlights(gtk_outputs)
      render_lines(gtk_outputs)
      render_scroll_buttons(gtk_outputs)
    end

    def address_visible?(address)
      address >= @offset && address <= maximum_visible_address
    end

    def maximum_visible_address
      @rendered_lines.last[:address] + @rendered_lines.last[:operation][:length] - 1
    end

    private

    def reset_highlights
      @highlights = []
    end

    def calc_rendered_lines
      @rendered_lines = []

      y = top - vertical_padding
      address = @offset
      while y > @y + vertical_padding
        parse_next_line until @parsed_up_to >= address
        line = @lines[address]

        @rendered_lines << line.merge(
          rect: { x: @x + 10, y: y - 20, w: @w - 20, h: 20 },
          comment: @comments[address]
        )
        address = line[:next_address]
        break if address >= @bytes.length

        y -= 20
      end
    end

    def parse_next_line
      if @lines.empty?
        address = 0
        previous_address = nil
      else
        address = @lines[@parsed_up_to][:next_address]
        previous_address = @parsed_up_to
      end

      next_line = if @memory_areas.key?(address)
                    build_memory_area_line(address, previous_address)
                  else
                    build_operation_line(address, previous_address)
                  end
      @parsed_up_to = address
      @lines[address] = next_line
    end

    def build_memory_area_line(address, previous_address)
      memory_area = @memory_areas[address]
      {
        address: address,
        previous_address: previous_address,
        next_address: address + memory_area[:length],
        text: memory_area[:name],
        operation: { type: :DATA, length: memory_area[:length] }
      }
    end

    def build_operation_line(address, previous_address)
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

      result = {
        address: address,
        previous_address: previous_address,
        next_address: address + operation[:length],
        text: "#{operation[:type]} #{argument_strings.join(', ')}",
        operation: operation,
        target_address: calc_target_address(address, operation)
      }
      result.compact!
      result
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
      @hovered_line = @rendered_lines.find { |line|
        args.inputs.mouse.inside_rect? line[:rect]
      }
      return unless @hovered_line

      @highlights << {
        address: hovered_line[:address],
        color: HOVER_COLOR
      }
      return unless hovered_line[:target_address]

      @highlights << {
        address: hovered_line[:target_address],
        color: JUMP_TARGET_COLOR
      }
    end

    def handle_scroll(args)
      mouse = args.inputs.mouse
      return unless mouse.click

      if can_scroll_up?
        if mouse.inside_rect? page_up_rect
          number_of_visible_lines.times do
            scroll_up_one_line
            break if @offset.zero?
          end
          return true
        end
        if mouse.inside_rect? one_line_up_rect
          scroll_up_one_line
          return true
        end
      end

      if can_scroll_down?
        if mouse.inside_rect? page_down_rect
          number_of_visible_lines.times do
            scroll_down_one_line
            break if @offset >= @bytes.length
          end
          return true
        end
        if mouse.inside_rect? one_line_down_rect
          scroll_down_one_line
          return true
        end
      end
    end

    def scroll_up_one_line
      @offset = @lines[@offset][:previous_address]
    end

    def scroll_down_one_line
      @offset = @lines[@offset][:next_address]
    end

    def handle_toggle_breakpoint(args)
      return unless args.inputs.mouse.click && @hovered_line

      address = @hovered_line[:address]
      if @breakpoints.key? address
        @breakpoints.delete address
      else
        @breakpoints[address] = true
      end
    end

    def render_highlights(gtk_outputs)
      gtk_outputs.primitives << @highlights.map { |highlight|
        next unless highlight[:address] >= @offset && highlight[:address] <= maximum_visible_address

        highlight_line = @rendered_lines.find { |line|
          line[:address] == highlight[:address]
        }
        next unless highlight_line

        gtk_outputs.primitives << highlight_line[:rect].merge(path: :pixel).sprite!(highlight[:color])
      }
    end

    def render_lines(gtk_outputs)
      gtk_outputs.primitives << @rendered_lines.map { |line|
        x = line[:rect][:x]
        y = line[:rect][:y] + 20
        address = line[:address]
        line_primitives = [
          {
            x: x, y: y, text: '%04X' % address,
            r: 100, g: 100, b: 100
          }.label!,
          {
            x: x + 80, y: y, text: line[:text]
          }.label!
        ]
        if line[:comment]
          line_primitives << {
            x: x + 250, y: y, text: line[:comment],
            r: 100, g: 100, b: 100
          }.label!
        end
        if @breakpoints.key? address
          line_primitives << {
            x: x + 65 , y: y, text: 'B', r: 255, g: 0, b: 0
          }.label!
        end
        line_primitives
      }
    end

    def render_scroll_buttons(gtk_outputs)
      if can_scroll_up?
        gtk_outputs.primitives << [
          page_up_rect.to_sprite(path: 'sprites/page_down.png', flip_vertically: true).merge!(SCROLL_BUTTON_COLOR),
          one_line_up_rect.to_sprite(path: 'sprites/down.png', flip_vertically: true).merge!(SCROLL_BUTTON_COLOR)
        ]
      end

      if can_scroll_down?
        gtk_outputs.primitives << [
          page_down_rect.to_sprite(path: 'sprites/page_down.png').merge!(SCROLL_BUTTON_COLOR),
          one_line_down_rect.to_sprite(path: 'sprites/down.png').merge!(SCROLL_BUTTON_COLOR)
        ]
      end
    end

    SCROLL_BUTTON_COLOR = { r: 100, g: 100, b: 100 }.freeze

    def number_of_visible_lines
      (@h - (vertical_padding * 2)).idiv(20)
    end

    def page_up_rect
      { x: 50, y: @y + @h - 40, w: 30, h: 30 }
    end

    def one_line_up_rect
      { x: 50, y: @y + @h - 80, w: 30, h: 30 }
    end

    def page_down_rect
      { x: 50, y: @y + 10, w: 30, h: 30 }
    end

    def one_line_down_rect
      { x: 50, y: @y + 50, w: 30, h: 30 }
    end

    def can_scroll_up?
      @offset.positive?
    end

    def can_scroll_down?
      maximum_visible_address < @bytes.length - 1
    end

    def format_hex_value(value, byte_count:)
      "$%0#{byte_count * 2}X" % value
    end

    def vertical_padding
      15
    end
  end
end
