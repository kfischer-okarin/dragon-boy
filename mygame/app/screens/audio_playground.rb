module Screens
  class AudioPlayground
    def initialize(args)
      args.state.audio_playground = args.state.new_entity(:audio_playground) do |state|
      end
      @apu = APU.new
    end

    def tick(args)
      @state = args.state.audio_playground

      process_input(args)
      render(args)
    end

    private

    def process_input(args)
      key_down = args.inputs.keyboard.key_down

      if key_down.escape
        $screen = Screens::RomSelection.new(args)
      end
    end

    def render(args)

    end
  end
end

$gtk.reset
