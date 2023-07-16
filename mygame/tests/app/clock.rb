require 'tests/test_helper.rb'

def test_clock_new_clock_has_empty_schedule(_args, assert)
  clock = build_clock

  assert.equal! clock.schedule, []
end

def test_clock_schedule_method_adds_method_at_the_right_point_in_schedule(_args, assert)
  clock = build_clock

  clock.schedule_method 10, :foo
  clock.schedule_method 5, :bar

  assert.equal! clock.schedule, [
    { cycle: 5, method: :bar },
    { cycle: 10, method: :foo }
  ]
end

def test_clock_clear_schedule(_args, assert)
  clock = build_clock

  clock.schedule_method 10, :foo
  clock.schedule_method 5, :bar
  clock.clear_schedule

  assert.equal! clock.schedule, []
end

def test_clock_advance_executes_all_methods_scheduled_next(_args, assert)
  clock = build_clock
  method_calls = listen_for_method_calls clock, [:foo, :bar]
  clock.schedule_method 12, :foo
  clock.schedule_method 12, :bar
  clock.schedule_method 15, :explode

  clock.advance

  assert.equal! method_calls, [:foo, :bar]
end

def test_clock_advance_removes_executed_methods_from_schedule(_args, assert)
  clock = build_clock
  clock.define_singleton_method :foo do; end
  clock.schedule_method 12, :foo
  clock.schedule_method 15, :bar

  clock.advance

  assert.equal! clock.schedule, [{ cycle: 15, method: :bar }]
end

def test_clock_advance_does_nothing_when_schedule_is_empty(_args, assert)
  clock = build_clock

  clock.advance

  assert.ok!
end

def test_clock_advance_can_process_the_last_schedule_item(_args, assert)
  clock = build_clock
  clock.define_singleton_method :foo do; end
  clock.schedule_method 12, :foo

  clock.advance

  assert.equal! clock.schedule, []
end

def test_clock_advance_updates_cycle(_args, assert)
  clock = build_clock
  clock.define_singleton_method :foo do; end
  clock.clear_schedule
  clock.schedule_method 12, :foo

  clock.advance

  assert.equal! clock.cycle, 12
end

def test_clock_advance_to_cycle_updates_cycle(_args, assert)
  clock = build_clock

  clock.advance_to_cycle 12

  assert.equal! clock.cycle, 12
end

def test_clock_advance_to_cycle_executes_all_methods_scheduled_until_that_cycle(_args, assert)
  clock = build_clock
  method_calls = listen_for_method_calls clock, [:foo, :bar]
  clock.schedule_method 12, :foo
  clock.schedule_method 13, :bar
  clock.schedule_method 15, :explode

  clock.advance_to_cycle 14

  assert.equal! method_calls, [:foo, :bar]
  assert.equal! clock.cycle, 14
end

def test_clock_schedule_method_should_schedule_past_items_after_4mhz(_args, assert)
  clock = build_clock
  clock.advance_to_cycle 2000
  clock.schedule_method 4_194_303, :foo
  clock.schedule_method 1000, :bar

  assert.equal! clock.schedule, [
    { cycle: 4_194_303, method: :foo },
    { cycle: 1000, method: :bar }
  ]
end

def test_clock_advance_to_cycle_advance_to_past_cycle_must_go_to_the_end_first(_args, assert)
  clock = build_clock
  method_calls = listen_for_method_calls clock, [:foo, :bar]
  clock.advance_to_cycle 2000
  clock.schedule_method 4_194_303, :foo
  clock.schedule_method 1000, :bar
  clock.schedule_method 1500, :explode

  clock.advance_to_cycle 1200

  assert.equal! method_calls, [:foo, :bar]
end

def test_clock_schedule_next_cpu_operation(_args, assert)
  cpu = Object.new
  cpu.define_singleton_method :next_operation_duration do
    32
  end
  clock = build_clock cpu: cpu

  clock.schedule_next_cpu_operation

  assert.contains! clock.schedule, { cycle: 32, method: :execute_next_operation }
end

def test_clock_execute_next_operation(_args, assert)
  cpu = Object.new
  cpu_called = false
  cpu.define_singleton_method :execute_next_operation do
    cpu_called = true
  end
  cpu.define_singleton_method :next_operation_duration do
    cpu_called ? 32 : 16
  end
  clock = build_clock cpu: cpu

  clock.execute_next_operation

  assert.true! cpu_called
  assert.contains! clock.schedule, { cycle: 32, method: :execute_next_operation }
end
