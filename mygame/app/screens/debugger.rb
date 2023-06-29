module Screens
  class Debugger
    def initialize(args, game_boy:)
      args.state.debugger = args.state.new_entity(:debugger) do |state|
        state.game_boy = game_boy
      end
      @registers_view = UI::RegistersView.new(game_boy.registers, x: 1080, y: 0, w: 200, h: 250)
    end

    def tick(args)
      @state = args.state.debugger

      @registers_view.render(args.outputs)
    end
  end
end
