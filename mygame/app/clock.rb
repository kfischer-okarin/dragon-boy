class Clock
  attr_reader :schedule, :cycle

  CYCLES_PER_SECOND = 4_194_304

  def initialize(cpu:)
    @cpu = cpu
    @schedule = []
    @cycle = 0
  end

  def schedule_method(cycle, method)
    @schedule << { cycle: cycle, method: method }
    @schedule = @schedule.sort_by { |item| effective_cycle(item[:cycle]) }
  end

  def clear_schedule
    @schedule = []
  end

  def advance_to_cycle(cycle)
    advance while @schedule.any? && @schedule.first[:cycle] <= effective_cycle(cycle)

    @cycle = cycle
  end

  def advance
    return if @schedule.empty?

    next_cycle_with_method = @schedule.first[:cycle]
    @cycle = next_cycle_with_method
    while @schedule.any? && @schedule.first[:cycle] == next_cycle_with_method
      method = @schedule.shift[:method]
      send method
    end
  end

  def schedule_next_cpu_operation
    schedule_method @cycle + @cpu.next_operation_duration, :execute_next_operation
  end

  def execute_next_operation
    duration = @cpu.next_operation_duration
    @cpu.execute_next_operation
    schedule_method @cycle + duration, :execute_next_operation
  end

  private

  def effective_cycle(cycle)
    if cycle < @cycle
      cycle + CYCLES_PER_SECOND
    else
      cycle
    end
  end
end

