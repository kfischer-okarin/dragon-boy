require_relative 'sampler.rb'

class APU
  class PulseChannel < Sampler
    CLOCK_FREQUENCY = 1_048_576

    def initialize(output_sample_rate:, sample_period:, duty_cycle:)
      super(
        clock_frequency: CLOCK_FREQUENCY,
        output_sample_rate: output_sample_rate,
        sample_period: sample_period,
        sample: []
      )
      self.duty_cycle = duty_cycle
    end

    def duty_cycle=(value)
      raise ArgumentError, "Invalid duty cycle: #{value}" unless DUTY_CYCLES.key?(value)

      self.sample = DUTY_CYCLES[value]
      @duty_cycle = value
    end

    DUTY_CYCLES = {
      0.125 => [0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0x0].freeze,
      0.250 => [0x0, 0xF, 0xF, 0xF, 0xF, 0xF, 0xF, 0x0].freeze,
      0.500 => [0x0, 0xF, 0xF, 0xF, 0xF, 0x0, 0x0, 0x0].freeze,
      0.750 => [0xF, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0xF].freeze
    }.freeze
  end
end
