require_relative 'sampler.rb'

class APU
  class PulseChannel < Sampler
    CLOCK_FREQUENCY = 1_048_576

    def initialize(output_sample_rate:, sample_period:, duty_cycle:)
      super(
        clock_frequency: CLOCK_FREQUENCY,
        output_sample_rate: output_sample_rate,
        sample_period: sample_period,
        sample: [0x0, 0xF, 0xF, 0xF, 0xF, 0x0, 0x0, 0x0]
      )
    end
  end
end
