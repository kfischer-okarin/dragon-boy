require 'tests/test_helper.rb'

def test_lcd_is_in_oam_scan_of_scanline_0_initially(_args, assert)
  lcd = build_lcd

  assert.equal! lcd.mode, :oam_scan
  assert.equal! lcd.scanline, 0
end

[
  { mode_change: [:oam_scan, :pixel_transfer], scanline_change: [0, 0] },
  { mode_change: [:pixel_transfer, :hblank], scanline_change: [0, 0] },
  { mode_change: [:hblank, :oam_scan], scanline_change: [0, 1] },
  { mode_change: [:hblank, :vblank], scanline_change: [143, 144] },
  { mode_change: [:vblank, :vblank], scanline_change: [144, 145] },
  { mode_change: [:vblank, :oam_scan], scanline_change: [153, 0] }
].each do |test_case|
  mode_before, mode_after = test_case[:mode_change]
  scanline_before, scanline_after = test_case[:scanline_change]

  define_method "test_lcd_advance_scanline_from_#{mode_before}#{scanline_before}_to_#{mode_after}#{scanline_after}" do |_args, assert|
    lcd = build_lcd
    lcd.mode = mode_before
    lcd.scanline = scanline_before

    lcd.advance_scanline

    assert.equal! lcd.mode, mode_after
    assert.equal! lcd.scanline, scanline_after
  end
end
