# frozen_string_literal: true

# rbs_inline: enabled

require "json"

require_relative "glamour/version"

begin
  major, minor, _patch = RUBY_VERSION.split(".") #: [String, String, String]
  require_relative "glamour/#{major}.#{minor}/glamour"
rescue LoadError
  require_relative "glamour/glamour"
end

require_relative "glamour/renderer"
require_relative "glamour/style"

module Glamour
  class << self
    alias render_native render

    # @rbs markdown: String -- the markdown content to render
    # @rbs style: String | singleton(Glamour::Style) -- style name or Style subclass
    # @rbs width: Integer -- optional word wrap width
    # @rbs return: String -- rendered output with ANSI escape codes
    def render(markdown, style: "auto", width: 0, **options)
      if style_class?(style)
        render_with_style_class(markdown, style, width: width, **options)
      else
        render_native(markdown, style: style, width: width, **options)
      end
    end

    # @rbs markdown: String -- the markdown content to render
    # @rbs style: Hash[Symbol, untyped] | String | singleton(Glamour::Style) -- style definition
    # @rbs width: Integer -- optional word wrap width
    # @rbs return: String -- rendered output with ANSI escape codes
    def render_with_style(markdown, style, width: 0)
      json_style = style_to_json(style)

      render_with_json(markdown, json_style, width: width)
    end

    private

    # @rbs style: untyped
    # @rbs return: bool
    def style_class?(style)
      style.is_a?(Class) && style.respond_to?(:glamour_style?) && style.glamour_style?
    end

    # @rbs style: Hash[Symbol, untyped] | String | singleton(Glamour::Style)
    # @rbs return: String
    def style_to_json(style)
      case style
      when Class
        raise ArgumentError, "Expected Glamour::Style subclass, got #{style}" unless style_class?(style)

        style.to_json
      when Hash
        JSON.generate(style)
      when String
        style
      else
        raise ArgumentError, "Expected Style class, Hash, or JSON string, got #{style.class}"
      end
    end

    # @rbs markdown: String -- the markdown content to render
    # @rbs style_class: singleton(Glamour::Style) -- the Style subclass
    # @rbs width: Integer -- optional word wrap width
    # @rbs return: String -- rendered output with ANSI escape codes
    def render_with_style_class(markdown, style_class, width: 0, **_options)
      styles = style_class.to_h

      if styles.empty?
        render_native(markdown, style: "auto", width: width)
      else
        render_with_json(markdown, JSON.generate(styles), width: width)
      end
    end
  end
end
