module GTK
  class Assert
    # Asserts that the given block raises an exception.
    # You can optionally specify the exception class that is expected to be raised.
    # If you don't specify an exception class, any exception will be accepted.
    #
    #   assert.exception_raised! do
    #     raise 'Boom!!!'
    #   end
    #
    #   assert.exception_raised!(RuntimeError) do
    #     raise 'Boom!!!'
    #   end
    #
    #   assert.exception_raised!(RuntimeError, 'No boom?') do
    #     # No boom
    #   end
    def exception_raised!(exception_class_or_message = nil, message = nil)
      if exception_class_or_message.is_a?(String) || exception_class_or_message.nil?
        exception_raised = false
        begin
          yield
        rescue StandardError
          exception_raised = true
        end

        if !exception_raised
          raise "Expected exception to be raised but no exception was raised.\n#{exception_class_or_message}"
        end
      else
        raised_exception_class = nil
        begin
          yield
        rescue StandardError => e
          raised_exception_class = e.class
        end

        if raised_exception_class.nil?
          raise "Expected exception #{exception_class} to be raised but no exception was raised.\n#{message}"
        elsif !raised_exception_class.ancestors.include?(exception_class)
          raise "Expected exception #{exception_class} to be raised but #{raised_exception_class} was raised.\n#{message}"
        end
      end

      @assertion_performed = true
    end

    def contains!(collection, item, message = nil)
      if !collection.include?(item)
        raise "Expected\n#{$fn.pretty_format(collection)}\n\nto contain:\n\n#{item}.\n#{message}"
      end

      @assertion_performed = true
    end
  end
end
