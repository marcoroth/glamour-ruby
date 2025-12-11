# frozen_string_literal: true

# rbs_inline: enabled

require_relative "style_definition"

module Glamour
  class Style
    class << self
      # @rbs @styles: Hash[Symbol, Hash[Symbol, untyped]]

      # @rbs element: Symbol | String -- the element to style
      # @rbs return: Hash[Symbol, untyped] -- the style definition
      def style(element, &)
        styles[element.to_sym] = StyleDefinition.new(&).to_h
      end

      # @rbs return: Hash[Symbol, Hash[Symbol, untyped]]
      def styles
        @styles ||= {}
      end

      # @rbs return: Hash[String, Hash[Symbol, untyped]]
      def to_h
        styles.transform_keys(&:to_s)
      end

      # @rbs return: String
      def to_json(*_args)
        JSON.generate(to_h)
      end

      # @rbs markdown: String -- the markdown content to render
      # @rbs width: Integer -- optional word wrap width
      # @rbs return: String -- rendered output with ANSI escape codes
      def render(markdown, width: 0, **)
        Glamour.render(markdown, style: self, width: width, **)
      end

      # @rbs return: true
      def glamour_style?
        true
      end
    end
  end
end
