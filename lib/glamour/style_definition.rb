# frozen_string_literal: true

# rbs_inline: enabled

module Glamour
  class StyleDefinition
    # @rbs @attributes: Hash[Symbol, untyped]
    # @rbs return: void
    def initialize(&)
      @attributes = {}
      instance_eval(&) if block_given?
    end

    # @rbs return: Hash[Symbol, untyped]
    def to_h
      @attributes
    end

    private

    # @rbs name: Symbol -- the attribute name
    # @rbs value: untyped -- the attribute value
    # @rbs return: untyped
    def method_missing(name, value = nil, &)
      @attributes[name] = if block_given?
                            StyleDefinition.new(&).to_h
                          else
                            value
                          end
    end

    # @rbs _name: Symbol
    # @rbs _include_private: bool
    # @rbs return: true
    def respond_to_missing?(_name, _include_private = false)
      true
    end
  end
end
