require 'tests/test_helper.rb'

def test_clock_new_clock_has_cpu_scheduled_on_cycle0(_args, assert)
  clock = Clock.new cpu: build_cpu

  assert.contains! clock.schedule, { cycle: 0, method: :execute_next_operation }
end

def test_clock_schedule_method_adds_method_at_the_right_point_in_schedule(_args, assert)
  clock = Clock.new cpu: build_cpu

  clock.schedule_method 10, :foo
  clock.schedule_method 5, :bar

  only_foo_bar_schedule = clock.schedule.select { |item|
    item[:method] == :foo || item[:method] == :bar
  }
  assert.equal! only_foo_bar_schedule, [
    { cycle: 5, method: :bar },
    { cycle: 10, method: :foo }
  ]
end
