module Screens
  class Debugger
    def initialize(args, game_boy:)
      args.state.debugger = args.state.new_entity(:debugger) do |state|
        state.game_boy = game_boy
        state.running = false
        state.displayed_view = :memory
      end
      registers_view_h = 250
      @program_view = UI::ProgramView.new(game_boy.memory, x: 0, y: 0, w: 640, h: 720)
      @program_view.offset = game_boy.registers.pc
      @program_view.comments = load_comments(game_boy)
      @registers_view = UI::RegistersView.new(game_boy.registers, x: 1080, y: 0, w: 200, h: registers_view_h)

      @memory_view = UI::MemoryView.new(game_boy.memory, x: 640, y: registers_view_h, w: 640, h: 720 - registers_view_h)
      @memory_view.offset = game_boy.registers.pc & 0xFFF0
      @sound_view = UI::SoundView.new(game_boy.io, x: 640, y: registers_view_h, w: 640, h: 720 - registers_view_h)
      @vram_view = UI::VRAMView.new(game_boy.vram, x: 640, y: registers_view_h, w: 640, h: 720 - registers_view_h)

      @misc_info_view = UI::MiscInfoView.new(game_boy, x: 640, y: 0, w: 200, h: registers_view_h)
    end

    def tick(args)
      @state = args.state.debugger
      game_boy = @state.game_boy

      process_inputs(args)

      @program_view.update(args)
      @program_view.highlights << { address: game_boy.registers.pc, color: UI::RegistersView::PC_COLOR }

      @program_view.render(args.outputs)
      @registers_view.render(args.outputs)
      send "render_#{@state.displayed_view}_view", args
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

    def process_inputs(args)
      keyboard = args.inputs.keyboard
      game_boy = @state.game_boy

      pc_before = @state.game_boy.registers.pc
      @state.running = !@state.running if keyboard.key_down.enter
      game_boy.cpu.execute_next_operation if keyboard.key_down.space
      if @state.running
        1000.times do
          game_boy.cpu.execute_next_operation
          if @program_view.breakpoints.key? game_boy.registers.pc
            @state.running = false
            break
          end
        end
      end

      scroll_to_pc_if_needed if @state.game_boy.registers.pc != pc_before

      if keyboard.key_down.one
        @state.displayed_view = :memory
      elsif keyboard.key_down.two
        @state.displayed_view = :sound
      elsif keyboard.key_down.three
        @state.displayed_view = :vram
      end

      $screen = Screens::RomSelection.new(args) if keyboard.key_down.escape
    end

    def render_memory_view(args)
      game_boy = @state.game_boy

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
      @memory_view.render(args.outputs)
    end

    def render_sound_view(args)
      @sound_view.render(args.outputs)
    end

    def render_vram_view(args)
      @vram_view.render(args.outputs)
    end

    def scroll_to_pc_if_needed
      pc = @state.game_boy.registers.pc
      @program_view.offset = pc unless @program_view.address_visible? pc
      @memory_view.offset = pc & 0xFFF0 unless @memory_view.address_visible? pc
    end
  end
end
