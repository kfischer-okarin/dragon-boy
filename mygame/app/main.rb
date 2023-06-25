require 'app/program.rb'
require 'app/registers.rb'
require 'app/screens/rom_selection.rb'
require 'app/screens/rom_viewer.rb'

def tick(args)
  setup(args) if args.tick_count.zero?
  $screen.tick(args)
end

def setup(args)
  $screen = Screens::RomSelection.new(args)
end

$gtk.reset
