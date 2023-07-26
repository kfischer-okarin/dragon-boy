def test_sampler_next_samples_divisible_sample_rates(_args, assert)
  sampler = APU::Sampler.new(
    clock_frequency: 100,
    output_sample_rate: 20,
    sample_period: 10,
    sample: [0x0, 0x1, 0xF]
  )

  output_samples = sampler.next_samples(7)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
  # Sample 0                   1                   F
  # Output 0         0         1         1         F
  assert.equal! output_samples, [0x0, 0x0, 0x1, 0x1, 0xF, 0xF, 0x0]

  output_samples = sampler.next_samples(2)

  assert.equal! output_samples, [0x0, 0x1]
end

def test_sampler_next_samples_indivisible_sample_rates(_args, assert)
  sampler = APU::Sampler.new(
    clock_frequency: 20,
    output_sample_rate: 7,
    sample_period: 3,
    sample: [0x0, 0x1, 0x2]
  )

  output_samples = sampler.next_samples(7)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
  # Sample 0     1     2     0     1     2     0
  # Output 0   0     1     2     0     1     2
  assert.equal! output_samples, [0x0, 0x0, 0x1, 0x2, 0x0, 0x1, 0x2]

  output_samples = sampler.next_samples(7)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
  # Sample   1     2     0     1     2     0     1
  # Output 0   1     2     0     1     2     0
  assert.equal! output_samples, [0x0, 0x1, 0x2, 0x0, 0x1, 0x2, 0x0]

  output_samples = sampler.next_samples(7)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
  # Sample     2     0     1     2     0     1
  # Output 1   2     0     1     2     0     1
  assert.equal! output_samples, [0x1, 0x2, 0x0, 0x1, 0x2, 0x0, 0x1]

  output_samples = sampler.next_samples(7)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
  # Sample 2     0     1     2     0     1     2
  # Output 2   2     0     1     2     0     1
  assert.equal! output_samples, [0x2, 0x2, 0x0, 0x1, 0x2, 0x0, 0x1]
end

def test_sampler_samples_until_cycle(_args, assert)
  sampler = APU::Sampler.new(
    clock_frequency: 100,
    output_sample_rate: 20,
    sample_period: 10,
    sample: [0x0, 0x1, 0xF]
  )

  output_samples = sampler.samples_until_cycle(23)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5
  # Sample 0                   1                   F
  # Output 0         0         1         1         F         F
  assert.equal! output_samples, [0x0, 0x0, 0x1, 0x1, 0xF]

  output_samples = sampler.samples_until_cycle(25)

  assert.equal! output_samples, [0xF]

  assert.equal! sampler.samples_until_cycle(25), [] # Don't return the same sample twice
end

def test_sampler_samples_until_cycle_wrap_around(_args, assert)
  sampler = APU::Sampler.new(
    clock_frequency: 20,
    output_sample_rate: 7,
    sample_period: 3,
    sample: [0x0, 0x1, 0x2]
  )

  output_samples = sampler.samples_until_cycle(16)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
  # Sample 0     1     2     0     1     2     0
  # Output 0   0     1     2     0     1     2
  assert.equal! output_samples, [0x0, 0x0, 0x1, 0x2, 0x0, 0x1]

  output_samples = sampler.samples_until_cycle(5)

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
  # Sample   1     2     0     1     2     0     1
  # Output 0   1     2     0     1     2     0
  assert.equal! output_samples, [0x2, 0x0, 0x1, 0x2]
end

def test_sampler_cycle_of_output_sample(_args, assert)
  sampler = APU::Sampler.new(
    clock_frequency: 20,
    output_sample_rate: 7,
    sample_period: 3,
    sample: [0x0, 0x1, 0x2]
  )

  # Clock  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9
  # Sample 0     1     2     0     1     2     0
  # Output 0   0     1     2     0     1     2
  assert.equal! sampler.cycle_of_output_sample(3), 8
end
