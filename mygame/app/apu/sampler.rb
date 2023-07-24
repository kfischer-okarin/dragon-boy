class APU
  class Sampler
    def initialize(clock_frequency:, output_sample_rate:, sample_period:, sample:)
      @clock_frequency = clock_frequency
      @output_sample_rate = output_sample_rate
      @sample_period = sample_period
      @sample = sample

      @sample_index = 0
      @current_sample = @sample[@sample_index]
      @next_sample_cycle = @sample_period
      self.output_sample_index = 0
    end

    def next_samples(count)
      result = []
      while result.length < count
        if @cycle < @next_sample_cycle
          result << @current_sample
          self.output_sample_index = @output_sample_index + 1
        else
          next_sample
        end
      end
      result
    end

    private

    def next_sample
      @sample_index = (@sample_index + 1) % @sample.length
      @current_sample = @sample[@sample_index]
      @next_sample_cycle += @sample_period
      if @next_sample_cycle >= @clock_frequency && @output_sample_index >= @output_sample_rate
        @next_sample_cycle -= @clock_frequency
        self.output_sample_index = @output_sample_index - @output_sample_rate
      end
    end

    def output_sample_index=(value)
      @cycle = (value * @clock_frequency).idiv(@output_sample_rate)
      @output_sample_index = value
    end
  end
end
