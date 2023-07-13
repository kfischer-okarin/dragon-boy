module UI
  class MiscInfoView
    attr_accessor :x, :y, :w, :h, :active_view

    attr_rect

    def initialize(game_boy, x:, y:, w:, h:)
      @game_boy = game_boy
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      x = @x + 10
      y = top - 10
      gtk_outputs.primitives << { x: x, y: y, text: 'Cycles: %9s' % format_with_1000_separator(@game_boy.cpu.cycles) }.label!
      y -= 20
      gtk_outputs.primitives << { x: x, y: y, text: "FPS: #{$gtk.current_framerate.to_i}" }.label!

      y -= 40
      debugger_tabs = Screens::Debugger::TABS
      debugger_tabs.keys.each_with_index do |key, index|
        color = @active_view == key ? { r: 0, g: 150, b: 0 } : { r: 0, g: 0, b: 0 }
        gtk_outputs.primitives << { x: x, y: y, text: "#{index + 1}) #{debugger_tabs[key]}" }.label!(color)
        y -= 20
      end
    end

    def format_with_1000_separator(number, separator = ',')
      result = number.to_s
      index = -4
      inserted_commas = 0
      while index.abs < result.length + inserted_commas
        result.insert index, separator
        inserted_commas += 1
        index -= 4
      end
      result
    end
  end
end
