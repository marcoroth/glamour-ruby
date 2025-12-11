# frozen_string_literal: true

require_relative "test_helper"

module Glamour
  class RendererTest < Minitest::Spec
    it "creates with default options" do
      renderer = Glamour::Renderer.new
      refute_nil renderer
      assert_equal "auto", renderer.style
      assert_equal 0, renderer.width
      assert_equal false, renderer.emoji
    end

    it "creates with custom options" do
      renderer = Glamour::Renderer.new(
        style: "dark",
        width: 80,
        emoji: true,
        preserve_newlines: true
      )
      assert_equal "dark", renderer.style
      assert_equal 80, renderer.width
      assert_equal true, renderer.emoji
      assert_equal true, renderer.preserve_newlines
    end

    it "renders markdown" do
      renderer = Glamour::Renderer.new(style: "dark")
      result = renderer.render("# Hello")
      refute_nil result
      assert_kind_of String, result
      assert_includes result, "Hello"
    end

    it "renders with json_style option" do
      json_style = '{"document": {"margin": 2}}'
      renderer = Glamour::Renderer.new(json_style: json_style)
      result = renderer.render("# Hello")
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with style_hash option" do
      style_hash = {
        document: { margin: 2 },
        heading: { bold: true, color: "212" },
        strong: { bold: true, color: "196" }
      }
      renderer = Glamour::Renderer.new(style_hash: style_hash)
      result = renderer.render("# Hello **World**")
      refute_nil result
      assert_kind_of String, result
      assert_includes result, "Hello"
    end

    it "is reusable for multiple renders" do
      renderer = Glamour::Renderer.new(style: "dark", width: 60)

      result1 = renderer.render("# First")
      result2 = renderer.render("# Second")

      refute_nil result1
      refute_nil result2
      assert_includes result1, "First"
      assert_includes result2, "Second"
    end

    it "accepts a Style class" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
          color "212"
        end
      end

      renderer = Glamour::Renderer.new(style: klass, width: 60)
      result = renderer.render("# Hello")
      refute_nil result
      assert_kind_of String, result
      assert_includes result, "Hello"
    end
  end
end
