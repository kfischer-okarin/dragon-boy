class Clock
  attr_reader :schedule

  def initialize(cpu:)
    @schedule = [
      { cycle: 0, method: :execute_next_operation }
    ]
  end

  def schedule_method(cycle, method)
    @schedule << { cycle: cycle, method: method }
    @schedule.sort! { |item1, item2| item1[:cycle] <=> item2[:cycle] }
  end

  def clear_schedule
    @schedule = []
  end

  def advance
    return if @schedule.empty?

    next_cycle_with_method = @schedule.first[:cycle]
    while @schedule.first[:cycle] == next_cycle_with_method
      method = @schedule.shift[:method]
      send method
    end
  end
end

