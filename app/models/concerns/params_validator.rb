  module ParamsValidator
    extend ActiveSupport::Concern

    included do
      def self.resolve_object(klass, value, error_message = nil)
        error_message ||= "Invalid #{klass.name.downcase}. Must be a #{klass.name} or Integer"
        raise ArgumentError, error_message unless value.is_a?(klass) || value.is_a?(Integer)
        value.is_a?(klass) ? value : klass.find(value)
      end
    end
  end