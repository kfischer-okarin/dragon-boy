class Clock
  attr_reader :schedule

  def initialize(cpu:)
    @schedule = [
      { cycle: 0, method: :execute_next_operation }
    ]
  end
end

