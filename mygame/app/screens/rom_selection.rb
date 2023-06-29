module Screens
  class RomSelection
    def initialize(args)
      args.state.rom_selection = args.state.new_entity(:rom_selection) do |state|
        state.available_roms = $gtk.list_files('roms').select { |file|
          ['.gb', '.gbc'].any? { |extension| file.end_with? extension }
        }
        letters = ('a'..'z').to_a
        state.rom_rects = state.available_roms.map.with_index { |rom, index|
          {
            x: 50, y: 650 - index * 25, w: $gtk.calcstringbox(rom, 1, 'font.ttf')[0], h: 20,
            rom: rom, letter: letters[index]
          }
        }
      end
    end

    def tick(args)
      @state = args.state.rom_selection

      process_input(args)
      render(args)
    end

    private

    def process_input(args)
      mouse = args.inputs.mouse
      @state.hovered_rom_rect = nil
      selected_rom = nil

      @state.hovered_rom_rect = @state.rom_rects.find { |rom_rect| mouse.inside_rect? rom_rect }
      if mouse.click && @state.hovered_rom_rect
        selected_rom = @state.hovered_rom_rect[:rom]
      end

      key_down = args.inputs.keyboard.key_down
      keyboard_selected_rom_rect = @state.rom_rects.find { |rom_rect| key_down.send(rom_rect[:letter]) }
      selected_rom = keyboard_selected_rom_rect[:rom] if keyboard_selected_rom_rect

      $screen = Screens::Debugger.new(args, game_boy: GameBoy.new(selected_rom)) if selected_rom
    end

    def render(args)
      args.outputs.primitives << {
        x: 10, y: 710, text: 'Select a ROM:', size_enum: 2
      }

      @state.rom_rects.each_with_index do |rom_rect, index|
        y = rom_rect[:y] + 20
        args.outputs.primitives << { x: rom_rect[:x] - 30, y: y, text: "#{rom_rect[:letter]})" }.label!
        args.outputs.primitives << {
          x: rom_rect[:x], y: rom_rect[:y] + 20, text: rom_rect[:rom]
        }.label!

        args.outputs.primitives << rom_rect.to_border(r: 0, g: 0, b: 0) if @state.hovered_rom_rect == rom_rect
      end

      $gtk.set_system_cursor @state.hovered_rom ? 'hand' : 'arrow'
    end
  end
end

$gtk.reset
