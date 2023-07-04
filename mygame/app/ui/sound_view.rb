module UI
  class SoundView
    attr_accessor :io, :x, :y, :w, :h

    attr_rect

    def initialize(io, x:, y:, w:, h:)
      @io = io
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      y = top - vertical_padding
      left_colum_x = @x + 10
      center_x = @x + (@w / 2)
      gtk_outputs.primitives << {
        x: center_x, y: y, text: 'Sound', size_enum: 2, alignment_enum: 1
      }.label!

      y -= 40
      gtk_outputs.primitives << {
        x: left_colum_x, y: y, text: "Sound System Status: #{fetch_value { @io.sound_on? ? 'ON' : 'OFF' }}"
      }.label!

      y -= 40
      gtk_outputs.primitives << { x: left_colum_x, y: y, text: 'Channel 1:', size_enum: 1.5 }.label!
      y -= 30
      channel1 = @io.sound_channel1
      gtk_outputs.primitives << { x: left_colum_x, y: y, text: "Duty Cycle: #{channel1[:duty_cycle]}" }.label!
      y -= 20
      gtk_outputs.primitives << { x: left_colum_x, y: y, text: "Length Timer: #{channel1[:length_timer]}" }.label!
    end

    def fetch_value
      yield
    rescue
      '---'
    end

    def vertical_padding
      15
    end
  end
end
