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
      left_column_x = @x + 10
      center_x = @x + (@w / 2)
      gtk_outputs.primitives << {
        x: center_x, y: y, text: 'Sound', size_enum: 2, alignment_enum: 1
      }.label!

      y -= 40
      gtk_outputs.primitives << {
        x: left_column_x, y: y,
        text: "Sound: #{@io.sound[:enabled] ? 'ON' : 'OFF'} - Volume: #{@io.sound[:volume_left]} / #{@io.sound[:volume_right] }"
      }.label!

      y -= 40
      channel1 = @io.sound_channel1
      gtk_outputs.primitives << { x: left_column_x, y: y, text: "Channel 1 (#{channel1[:panning]})", size_enum: 1.5 }.label!
      y -= 30
      y = render_duty_cycle_information(gtk_outputs, channel1, left_column_x, y)
      y -= 20
      y = render_volume_information(gtk_outputs, channel1, left_column_x, y)
      y -= 20
      y = render_pulse_frequency_information(gtk_outputs, channel1, left_column_x, y)

      y -= 40
      channel2 = @io.sound_channel2
      gtk_outputs.primitives << { x: left_column_x, y: y, text: "Channel 2 (#{channel2[:panning]})", size_enum: 1.5 }.label!
      y -= 30
      y = render_duty_cycle_information(gtk_outputs, channel2, left_column_x, y)
      y -= 20
      y = render_volume_information(gtk_outputs, channel2, left_column_x, y)
      y -= 20
      y = render_pulse_frequency_information(gtk_outputs, channel1, left_column_x, y)

      right_column_x = center_x + 10
      y = top - vertical_padding - 40 - 40
      channel3 = @io.sound_channel3
      gtk_outputs.primitives << { x: right_column_x, y: y, text: "Channel 3 (#{channel3[:panning]})", size_enum: 1.5 }.label!
      y -= 30
      y = render_volume_information(gtk_outputs, channel3, right_column_x, y)

      y -= 40
      channel4 = @io.sound_channel4
      gtk_outputs.primitives << { x: right_column_x, y: y, text: "Channel 4 (#{channel4[:panning]})", size_enum: 1.5 }.label!
      y -= 30
      y = render_volume_information(gtk_outputs, channel4, right_column_x, y)
    end

    def render_duty_cycle_information(gtk_outputs, channel, x, y)
      gtk_outputs.primitives << { x: x, y: y, text: "Duty Cycle: #{channel[:duty_cycle]}" }.label!
      y -= 20
      gtk_outputs.primitives << { x: x, y: y, text: "Length Timer: #{channel[:length_timer]}" }.label!
      y
    end

    def render_volume_information(gtk_outputs, channel, x, y)
      gtk_outputs.primitives << { x: x, y: y, text: "Volume: #{channel[:volume]}" }.label!
      y -= 20
      envelope_text = if channel[:envelope_sweep_timer].nil?
                        ''
                      elsif channel[:envelope_sweep_timer].zero?
                        'Disabled'
                      else
                        "#{channel[:envelope_direction]} every #{channel[:envelope_sweep_timer]}/64s"
                      end
      gtk_outputs.primitives << { x: x, y: y, text: "Envelope: #{envelope_text}" }.label!
      y
    end

    def render_pulse_frequency_information(gtk_outputs, channel, x, y)
      gtk_outputs.primitives << { x: x, y: y, text: "Frequency: #{channel[:frequency]}" }.label!
      y -= 20
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
