module Screens
  class Debugger
    def initialize(args, game_boy:)
      args.state.debugger = args.state.new_entity(:debugger) do |state|
        state.game_boy = game_boy
      end
      registers_view_h = 250
      @registers_view = UI::RegistersView.new(game_boy.registers, x: 1080, y: 0, w: 200, h: registers_view_h)
      @memory_view = UI::MemoryView.new(game_boy.memory, x: 640, y: registers_view_h, w: 640, h: 720 - registers_view_h)
    end

    def tick(args)
      @state = args.state.debugger

      @memory_view.highlights = []
      @memory_view.highlights << { address: @state.game_boy.registers.pc, color: UI::RegistersView::PC_COLOR }

      @registers_view.render(args.outputs)
      @memory_view.render(args.outputs)
    end
  end
end
