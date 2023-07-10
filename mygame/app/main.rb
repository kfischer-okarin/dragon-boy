require 'app/game_boy.rb'
require 'app/cpu.rb'
require 'app/game_boy_io.rb'
require 'app/memory.rb'
require 'app/operation.rb'
require 'app/registers.rb'
require 'app/vram.rb'
require 'app/screens/debugger.rb'
require 'app/screens/rom_selection.rb'
require 'app/ui/memory_view.rb'
require 'app/ui/misc_info_view.rb'
require 'app/ui/program_view.rb'
require 'app/ui/registers_view.rb'
require 'app/ui/sound_view.rb'
require 'app/ui/vram_view.rb'

def tick(args)
  setup(args) if args.tick_count.zero?
  $screen.tick(args)
end

def setup(args)
  args.state.settings = load_settings
  $screen = Screens::RomSelection.new(args)
end

def load_settings
  saved_settings = $gtk.parse_json_file 'settings.json'
  return saved_settings if saved_settings

  $gtk.write_file 'settings.json', <<~JSON
    {
      "boot_rom": null
    }
  JSON
  $gtk.parse_json_file 'settings.json'
end

$gtk.reset
