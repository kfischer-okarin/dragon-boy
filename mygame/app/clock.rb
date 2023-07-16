class Clock
  attr_reader :schedule, :cycle, :seconds

  CYCLES_PER_SECOND = 4_194_304

  def initialize(cpu:, lcd:)
    @cpu = cpu
    @lcd = lcd
    @schedule = []
    @cycle = 0
    @seconds = 0
  end

  def schedule_method(cycle, method)
    @schedule << { cycle: cycle % CYCLES_PER_SECOND, method: method }
    @schedule = @schedule.sort_by { |item| effective_cycle(item[:cycle]) }
  end

  def clear_schedule
    @schedule = []
  end

  def advance_to_cycle(cycle)
    advance while @schedule.any? && @schedule.first[:cycle] <= effective_cycle(cycle)

    self.cycle = cycle
  end

  def advance
    return if @schedule.empty?

    next_cycle_with_method = @schedule.first[:cycle]
    self.cycle = next_cycle_with_method
    while @schedule.any? && @schedule.first[:cycle] == next_cycle_with_method
      method = @schedule.shift[:method]
      send method
    end
  end

  def schedule_next_cpu_operation
    schedule_method @cycle + @cpu.next_operation_duration, :execute_next_operation
  end

  def execute_next_operation
    @cpu.execute_next_operation
    schedule_next_cpu_operation
  end

  def schedule_next_lcd_scanline
    schedule_method @cycle + @lcd.current_mode_duration, :advance_lcd_scanline
  end

  def advance_lcd_scanline
    @lcd.advance_scanline
    schedule_next_lcd_scanline
  end

  private

  def effective_cycle(cycle)
    if cycle < @cycle
      cycle + CYCLES_PER_SECOND
    else
      cycle
    end
  end

  def cycle=(value)
    @seconds += effective_cycle(value).idiv(CYCLES_PER_SECOND)
    @cycle = value % CYCLES_PER_SECOND
  end
end

