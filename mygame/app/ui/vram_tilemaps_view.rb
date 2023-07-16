module UI
  class VRAMTilemapsView
    attr_accessor :vram, :lcd, :x, :y, :w, :h

    attr_rect

    def initialize(vram:, lcd:, x:, y:, w:, h:)
      @vram = vram
      @lcd = lcd
      @x = x
      @y = y
      @w = w
      @h = h
    end

    def render(gtk_outputs)
      gtk_outputs.primitives << [
        { x: @x, y: @y, w: @w + 1, h: @h + 1, r: 0, g: 0, b: 0 }.border!
      ]

      left_column_x = @x + 10
      center_x = @x + @w.idiv(2)
      right_column_x = center_x + 10
      y = top - vertical_padding
      gtk_outputs.primitives << [
        { x: left_column_x, y: y, text: 'Tilemap 0', size_enum: 2 }.label!,
        { x: right_column_x, y: y, text: 'Tilemap 1', size_enum: 2 }.label!
      ]

      y -= 40
      render_tilemap(gtk_outputs, 0, left_column_x, y)
      render_tilemap(gtk_outputs, 1, right_column_x, y)
      y -= 256 + 20
      gtk_outputs.primitives << {
        x: left_column_x, y: y, text: 'If above tilemaps are odd try displaying "Tiles & Objects"'
      }.label!
      y -= 20
      gtk_outputs.primitives << {
        x: left_column_x, y: y, text: 'first to refresh the tiles'
      }.label!
      # TODO: Fix this
    end

    def vertical_padding
      15
    end

    private

    def render_tilemap(gtk_outputs, index, x, top)
      render_target_name = "tilemap#{index}"
      render_target = gtk_outputs[render_target_name]
      render_target.transient!
      render_target.w = 256
      render_target.h = 256
      render_target.primitives << @vram.tilemap(index).tile_primitives

      gtk_outputs.primitives << {
        x: x, y: top - 256, w: 256, h: 256, path: render_target_name
      }.sprite!
      gtk_outputs.primitives << {
        x: x + @lcd.viewport_position[:x],
        y: top - @lcd.viewport_position[:y] - 144,
        w: 160,
        h: 144,
      }.border!
    end
  end
end
