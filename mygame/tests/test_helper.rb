module GTK
  class Assert
    def exception_raised!(exception_class_or_message = nil, message = nil)
      if exception_class_or_message.is_a?(String) || exception_class_or_message.nil?
        exception_raised = false
        begin
          yield
        rescue StandardError
          exception_raised = true
        end

        if !exception_raised
          raise "Expected exception to be raised but no exception was raised. #{exception_class_or_message}."
        end
      else
        raised_exception_class = nil
        begin
          yield
        rescue StandardError => e
          raised_exception_class = e.class
        end

        if raised_exception_class.nil?
          raise "Expected exception #{exception_class} to be raised but no exception was raised. #{message}."
        elsif !raised_exception_class.ancestors.include?(exception_class)
          raise "Expected exception #{exception_class} to be raised but #{raised_exception_class} was raised. #{message}."
        end
      end

      @assertion_performed = true
    end
  end
end

def build_cpu
  CPU.new registers: Registers.new, memory: Memory.new
end
