module Screens
  class Debugger
    TABS = {
      memory: 'Memory',
      sound: 'Sound Channels',
      vram_tiles: 'Tiles & Objects',
      vram_tilemaps: 'Tilemaps'
    }.freeze

    def initialize(args, game_boy:)
      args.state.debugger = args.state.new_entity(:debugger) do |state|
        state.game_boy = game_boy
        state.running = false
        state.displayed_view = :memory
      end
      @state = args.state.debugger

      registers_view_h = 250
      @program_view = UI::ProgramView.new(game_boy.memory, x: 0, y: 0, w: 640, h: 720)
      @program_view.offset = game_boy.registers.pc
      reload_comments
      @registers_view = UI::RegistersView.new(game_boy.registers, x: 1080, y: 0, w: 200, h: registers_view_h)

      right_view_rect = { x: 640, y: registers_view_h, w: 640, h: 720 - registers_view_h }
      @memory_view = UI::MemoryView.new(game_boy.memory, **right_view_rect)
      @memory_view.offset = game_boy.registers.pc & 0xFFF0
      @sound_view = UI::SoundView.new(game_boy.io, **right_view_rect)
      @vram_tiles_view = UI::VRAMTilesView.new(game_boy.vram, **right_view_rect)
      @vram_tilemaps_view = UI::VRAMTilemapsView.new(game_boy.vram, **right_view_rect)

      @misc_info_view = UI::MiscInfoView.new(game_boy, x: 640, y: 0, w: 200, h: registers_view_h)
    end

    def tick(args)
      @state = args.state.debugger
      @state.pc_at_start_of_tick = @state.game_boy.registers.pc

      process_inputs(args)

      update_game_boy

      update_program_view(args)
      send "update_#{@state.displayed_view}_view", args if respond_to? "update_#{@state.displayed_view}_view"
      update_misc_info_view

      @program_view.render(args.outputs)
      @registers_view.render(args.outputs)
      send "render_#{@state.displayed_view}_view", args
      @misc_info_view.render(args.outputs)
    end

    private

    def process_inputs(args)
      key_down = args.inputs.keyboard.key_down

      @state.operations_to_execute = 0
      if @state.running
        if key_down.enter
          @state.running = false
        else
          @state.operations_to_execute = 1000
        end
      else
        @state.operations_to_execute = 1 if key_down.space
        @state.running = true if key_down.enter
      end

      number_keys = [:one, :two, :three, :four, :five, :six, :seven, :eight, :nine, :zero]
      TABS.keys.each_with_index do |key, index|
        if key_down.send(number_keys[index])
          @state.displayed_view = key
          break
        end
      end

      reload_comments if key_down.c

      $screen = Screens::RomSelection.new(args) if key_down.escape
    end

    def update_game_boy
      game_boy = @state.game_boy

      @state.operations_to_execute.times do
        pc_before = game_boy.registers.pc
        game_boy.clock.advance until game_boy.registers.pc != pc_before
        if @program_view.breakpoints.key? game_boy.registers.pc
          @state.running = false
          break
        end
      end
    end

    def update_program_view(args)
      game_boy = @state.game_boy

      keep_pc_visible_in_program_view

      @program_view.update(args)
      @program_view.highlights << { address: game_boy.registers.pc, color: UI::RegistersView::PC_COLOR }
    end

    def keep_pc_visible_in_program_view
      pc = @state.game_boy.registers.pc
      return if pc == @state.pc_at_start_of_tick

      @program_view.offset = pc unless @program_view.address_visible?(pc)
    end

    def update_memory_view(args)
      game_boy = @state.game_boy

      unless @memory_view.address_visible?(@program_view.offset) &&
             @memory_view.address_visible?(@program_view.maximum_visible_address)
        @memory_view.offset = @program_view.offset & 0xFFF0
      end

      @memory_view.highlights = []
      @memory_view.highlights << {
        address: (@program_view.offset..@program_view.maximum_visible_address),
        color: { r: 200, g: 200, b: 200 },
        size: 3
      }
      hovered_line = @program_view.hovered_line
      if hovered_line
        address = hovered_line[:address]
        @memory_view.highlights << {
          address: (address..(address + hovered_line[:operation][:length] - 1)),
          color: UI::ProgramView::HOVER_COLOR,
          size: 2
        }
        if hovered_line[:target_address]
          @memory_view.highlights << {
            address: hovered_line[:target_address],
            color: UI::ProgramView::JUMP_TARGET_COLOR,
            size: 2
          }
        end
      end
      @memory_view.highlights << { address: game_boy.registers.pc, color: UI::RegistersView::PC_COLOR }
    end

    def render_memory_view(args)
      @memory_view.render(args.outputs)
    end

    def render_sound_view(args)
      @sound_view.render(args.outputs)
    end

    def update_vram_tiles_view(args)
      @vram_tiles_view.update(args)
    end

    def render_vram_tiles_view(args)
      @vram_tiles_view.render(args.outputs)
    end

    def render_vram_tilemaps_view(args)
      @vram_tilemaps_view.render(args.outputs)
    end

    def update_misc_info_view
      @misc_info_view.active_view = @state.displayed_view
    end

    def reload_comments
      game_boy = @state.game_boy
      @program_view.comments = comments = {}
      rom_comments = $gtk.parse_json_file("roms/#{game_boy.rom}.comments.json")
      comments.merge!(rom_comments.transform_keys { |address| address.to_i(16) }) if rom_comments
      boot_rom_comments = $gtk.parse_json_file("#{game_boy.boot_rom}.comments.json")
      comments.merge!(boot_rom_comments.transform_keys { |address| address.to_i(16) }) if boot_rom_comments
    end
  end
end
