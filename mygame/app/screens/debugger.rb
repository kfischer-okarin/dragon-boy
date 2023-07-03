module Screens
  class Debugger
    def initialize(args, game_boy:)
      args.state.debugger = args.state.new_entity(:debugger) do |state|
        state.game_boy = game_boy
        state.running = false
      end
      registers_view_h = 250
      @program_view = UI::ProgramView.new(game_boy.memory, x: 0, y: 0, w: 640, h: 720)
      @program_view.offset = game_boy.registers.pc
      @program_view.comments = load_comments(game_boy)
      @registers_view = UI::RegistersView.new(game_boy.registers, x: 1080, y: 0, w: 200, h: registers_view_h)
      @memory_view = UI::MemoryView.new(game_boy.memory, x: 640, y: registers_view_h, w: 640, h: 720 - registers_view_h)
      @memory_view.offset = game_boy.registers.pc & 0xFFF0
      @misc_info_view = UI::MiscInfoView.new(game_boy, x: 640, y: 0, w: 200, h: registers_view_h)
    end

    def tick(args)
      @state = args.state.debugger
      game_boy = @state.game_boy

      @state.running = !@state.running if args.inputs.keyboard.key_down.enter
      game_boy.cpu.execute_next_operation if args.inputs.keyboard.key_down.space
      if @state.running
        1000.times do
          game_boy.cpu.execute_next_operation
          if @program_view.breakpoints.key? game_boy.registers.pc
            @state.running = false
            break
          end
        end
      end
      $screen = Screens::RomSelection.new(args) if args.inputs.keyboard.key_down.escape

      @program_view.update(args)

      @program_view.highlights << { address: game_boy.registers.pc, color: UI::RegistersView::PC_COLOR }
      @memory_view.highlights = []
      @memory_view.highlights << {
        address: (@program_view.offset..@program_view.maximum_visible_address),
        color: { r: 200, g: 200, b: 200 },
        size: 3
      }
      if @program_view.hovered_operation
        address = @program_view.hovered_operation[:address]
        @memory_view.highlights << {
          address: (address..(address + @program_view.hovered_operation[:operation][:length] - 1)),
          color: UI::ProgramView::HOVER_COLOR,
          size: 2
        }
      end
      @memory_view.highlights << { address: game_boy.registers.pc, color: UI::RegistersView::PC_COLOR }

      @program_view.render(args.outputs)
      @registers_view.render(args.outputs)
      @memory_view.render(args.outputs)
      @misc_info_view.render(args.outputs)
    end

    private

    def load_comments(game_boy)
      result = {}
      rom_comments = $gtk.parse_json_file("roms/#{game_boy.rom}.comments.json")
      result.merge!(rom_comments.transform_keys { |address| address.to_i(16) }) if rom_comments
      boot_rom_comments = $gtk.parse_json_file("#{game_boy.boot_rom}.comments.json")
      result.merge!(boot_rom_comments.transform_keys { |address| address.to_i(16) }) if boot_rom_comments
      result
    end
  end
end
