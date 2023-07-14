require 'tests/test_helper.rb'

def test_clock_new_clock_has_cpu_scheduled_on_cycle0(_args, assert)
  clock = Clock.new cpu: build_cpu

  assert.contains! clock.schedule, { cycle: 0, method: :execute_next_operation }
end
