require_relative 'apu/pulse_channel.rb'

class APU
  SAMPLE_RATE = 44_100

  attr_reader :channel1

  def initialize
    @channel1 = PulseChannel.new(
      output_sample_rate: SAMPLE_RATE,
      sample_period: 0x6D6,
      duty_cycle: 0.5
    )
  end
end
