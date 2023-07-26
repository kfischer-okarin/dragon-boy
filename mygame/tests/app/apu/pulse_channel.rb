def test_pulse_channel(_args, assert)
  pulse_channel = APU::PulseChannel.new(
    output_sample_rate: 44_100,
    sample_period: 50,
    duty_cycle: 0.5
  )

  # 1 output sample per 23.77 clock cycles
  # (1_048_576 / 44_100) = 23.77

  output_samples = pulse_channel.samples_until_cycle(399)

  # Clock  0 23 47 50 71 95 100 118 142 150 166 190 200 213 237 250 261 285 300 309 332 350 356 380 399
  # Sample 0        F         F           F           F           0           0           0
  # Output 0  0  0     F  F       F   F       F   F       F   F       0   0       0   0       0   0
  assert.equal! output_samples, [0x0, 0x0, 0x0, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]
end
