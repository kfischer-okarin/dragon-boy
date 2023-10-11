require 'app/apu.rb'
require 'app/game_boy.rb'
require 'app/clock.rb'
require 'app/cpu.rb'
require 'app/game_boy_io.rb'
require 'app/lcd.rb'
require 'app/memory.rb'
require 'app/operation.rb'
require 'app/registers.rb'
require 'app/vram.rb'
require 'app/screens/audio_playground.rb'
require 'app/screens/debugger.rb'
require 'app/screens/rom_selection.rb'
require 'app/ui/lcd_view.rb'
require 'app/ui/memory_view.rb'
require 'app/ui/misc_info_view.rb'
require 'app/ui/program_view.rb'
require 'app/ui/registers_view.rb'
require 'app/ui/sound_view.rb'
require 'app/ui/vram_tilemaps_view.rb'
require 'app/ui/vram_tiles_view.rb'

def tick(args)
  setup(args) if args.tick_count.zero?
  $screen.tick(args)
end

# https://github.com/WerWolv/ImHex HEX EDITOR

# GB Refs
# - Pan Docs: https://gbdev.io/pandocs/
# - CPU Opcode reference: https://rgbds.gbdev.io/docs/v0.6.1/gbz80.7/
# - CPU Opcode table: https://gbdev.io/gb-opcodes//optables/



def setup(args)
  args.state.settings = load_settings
  $screen = Screens::RomSelection.new(args)

  args.state.period_value = 0x6D6
  p args.state.period_value
  output_sample_rate = 44_100
  output_samples_per_tick = (output_sample_rate / 60).ceil

  apu_cycles = 0
  output_sample_count = 0
  value_index = 0
  values = [-1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0]
  sound = {}
  sound[:input] = [
    1,
    output_sample_rate,
    lambda do
      apu_cycles_per_sample = 2048 - args.state.period_value
      result = []
      while result.length < output_samples_per_tick
        value = values[value_index]
        value_index = (value_index + 1) % values.length
        apu_cycles += apu_cycles_per_sample
        next_output_sample_count = ((apu_cycles * output_sample_rate) / 1_048_576).floor
        added_output_sample_count = next_output_sample_count - output_sample_count
        added_output_sample_count.times do
          result << value
        end
        output_sample_count = next_output_sample_count % output_sample_rate
        apu_cycles %= 1_048_576
      end
      result
    end
  ]
  #  # Generate 1 second worth of sound
  # args.audio[:sound] = sound
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
