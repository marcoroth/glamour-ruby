# frozen_string_literal: true

# rbs_inline: enabled

module Glamour
  class Renderer
    # @rbs hash: Hash[Symbol, untyped] -- style definition hash
    # @rbs return: String
    def style_hash=(hash)
      @json_style = JSON.generate(hash)
    end

    alias original_initialize initialize

    # @rbs style: String | singleton(Glamour::Style) -- style name or Style subclass
    # @rbs width: Integer -- optional word wrap width
    # @rbs emoji: bool -- whether to render emoji
    # @rbs preserve_newlines: bool -- whether to preserve newlines
    # @rbs base_url: String? -- base URL for relative links
    # @rbs color_profile: Symbol -- color profile to use
    # @rbs json_style: String? -- JSON style definition
    # @rbs style_hash: Hash[Symbol, untyped]? -- style definition hash
    # @rbs return: void
    def initialize(style: "auto", width: 0, emoji: false, preserve_newlines: false, base_url: nil,
                   color_profile: :auto, json_style: nil, style_hash: nil)
      actual_style = style
      actual_json_style = json_style

      if style.is_a?(Class) && style.respond_to?(:glamour_style?) && style.glamour_style?
        actual_style = "auto"
        actual_json_style = style.to_json unless style.to_h.empty?
      end

      actual_json_style = JSON.generate(style_hash) if style_hash

      original_initialize(
        style: actual_style,
        width: width,
        emoji: emoji,
        preserve_newlines: preserve_newlines,
        base_url: base_url,
        color_profile: color_profile,
        json_style: actual_json_style
      )
    end
  end
end
