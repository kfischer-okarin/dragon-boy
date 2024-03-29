class APU
  class Sampler
    attr_reader :sample

    def initialize(clock_frequency:, output_sample_rate:, sample_period:, sample:)
      @clock_frequency = clock_frequency
      @output_sample_rate = output_sample_rate
      @sample_period = sample_period
      @sample = sample

      @sample_index = 0
      @current_sample = @sample[@sample_index]
      @next_sample_cycle = @sample_period
      @output_sample_cycles = (0..@output_sample_rate).map do |index|
        (index * @clock_frequency).idiv(@output_sample_rate)
      end
      @output_sample_index = 0
      @cycle = 0
    end

    def sample=(value)
      @current_sample = value[@sample_index]
      @sample = value
    end

    def cycle_of_output_sample(index)
      @output_sample_cycles[index]
    end

    def next_samples(count)
      result = []
      result << next_output_sample while result.length < count
      result
    end

    def next_output_sample
      result = @current_sample
      @output_sample_index += 1
      @cycle = @output_sample_cycles[@output_sample_index]
      move_to_next_sample if @cycle >= @next_sample_cycle
      result
    end

    def samples_until_cycle(target_cycle)
      result = []
      return result if target_cycle == @cycle

      if target_cycle < @cycle # We need to loop around first
        result << next_output_sample until @output_sample_index.zero?
      end

      result << next_output_sample while @cycle <= target_cycle
      @cycle = target_cycle

      result
    end

    private

    def move_to_next_sample
      @sample_index = (@sample_index + 1) % @sample.length
      @current_sample = @sample[@sample_index]
      @next_sample_cycle += @sample_period
      if @next_sample_cycle >= @clock_frequency && @output_sample_index >= @output_sample_rate
        @next_sample_cycle -= @clock_frequency
        @output_sample_index -= @output_sample_rate
        @cycle = @output_sample_cycles[@output_sample_index]
      end
    end
  end
end
