module UI
  class RegistersView
    PC_COLOR = { r: 0, g: 200, b: 250 }.freeze

    attr_accessor :registers, :x, :y, :w, :h

    attr_rect

    def initialize(registers, x:, y:, w:, h:)
      @registers = registers
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def render(gtk_outputs)
      center_x = @x + (@w / 2)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w, h: @h + 1, r: 0, g: 0, b: 0 }.border!,
        { x: center_x, y: top - 10, text: 'Registers', size_enum: 2, alignment_enum: 1 }.label!,
      ]

      render_8bit_registers(gtk_outputs, x: center_x - 40, top: top - 50)
      render_16bit_registers(gtk_outputs, x: center_x + 40, top: top - 50)
      render_flags(gtk_outputs, x: center_x + 40, top: top - 160)
    end

    def render_8bit_registers(gtk_outputs, x:, top:)
      y = top
      gtk_outputs.primitives << [
        { x: x - 10, y: y, text: 'A', alignment_enum: 1 }.label!,
        { x: x + 10, y: y, text: 'F', alignment_enum: 1 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.a, alignment_enum: 2 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.f, alignment_enum: 0 }.label!
      ]
      y -= 45
      gtk_outputs.primitives << [
        { x: x - 10, y: y, text: 'B', alignment_enum: 1 }.label!,
        { x: x + 10, y: y, text: 'C', alignment_enum: 1 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.b, alignment_enum: 2 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.c, alignment_enum: 0 }.label!
      ]
      y -= 45
      gtk_outputs.primitives << [
        { x: x - 10, y: y, text: 'D', alignment_enum: 1 }.label!,
        { x: x + 10, y: y, text: 'E', alignment_enum: 1 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.d, alignment_enum: 2 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.e, alignment_enum: 0 }.label!
      ]
      y -= 45
      gtk_outputs.primitives << [
        { x: x - 10, y: y, text: 'H', alignment_enum: 1 }.label!,
        { x: x + 10, y: y, text: 'L', alignment_enum: 1 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.h, alignment_enum: 2 }.label!,
        { x: x, y: y - 20, text: '%02X' % @registers.l, alignment_enum: 0 }.label!
      ]
    end

    def render_16bit_registers(gtk_outputs, x:, top:)
      y = top
      gtk_outputs.primitives << [
        { x: x, y: y, text: 'SP', alignment_enum: 1 }.label!,
        { x: x, y: y - 20, text: '%04X' % @registers.sp, alignment_enum: 1 }.label!
      ]
      y -= 45
      gtk_outputs.primitives << [
        { x: x - 30, y: y - 40, w: 60, h: 40, path: :pixel }.sprite!(PC_COLOR),
        { x: x, y: y, text: 'PC', alignment_enum: 1 }.label!,
        { x: x, y: y - 20, text: '%04X' % @registers.pc, alignment_enum: 1 }.label!
      ]
    end

    def render_flags(gtk_outputs, x:, top:)
      y = top
      gtk_outputs.primitives << [
        { x: x, y: y, text: 'ZNHC', alignment_enum: 1 }.label!,
        { x: x, y: y - 20, text: '%04b' % (@registers.f >> 4), alignment_enum: 1 }.label!
      ]
    end
  end
end
