# frozen_string_literal: true

require_relative "test_helper"

module Glamour
  class GlamourTest < Minitest::Spec
    it "has a version number" do
      refute_nil ::Glamour::VERSION
    end

    it "has an upstream version" do
      refute_nil Glamour.upstream_version
      assert_match(/\d+\.\d+\.\d+/, Glamour.upstream_version)
    end

    it "returns info string from version method" do
      version = Glamour.version
      assert_includes version, "glamour"
      assert_includes version, Glamour::VERSION
      assert_includes version, Glamour.upstream_version
      assert_includes version, "Go native extension"
    end

    it "renders basic markdown" do
      result = Glamour.render("# Hello")
      refute_nil result
      assert_kind_of String, result
      assert_includes result, "Hello"
    end

    it "renders bold text" do
      result = Glamour.render("**bold**")
      refute_nil result
      assert_kind_of String, result
    end

    it "renders italic text" do
      result = Glamour.render("*italic*")
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with style option" do
      result = Glamour.render("# Hello", style: "dark")
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with notty style" do
      result = Glamour.render("# Hello", style: "notty")
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with width option" do
      long_text = "This is a very long paragraph " * 10
      result = Glamour.render(long_text, width: 40)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with style and width" do
      result = Glamour.render("# Hello World", style: "dark", width: 80)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders code block" do
      markdown = <<~MD
        ```ruby
        puts "hello"
        ```
      MD
      result = Glamour.render(markdown)
      refute_nil result
      assert_includes result, "puts"
    end

    it "renders empty string" do
      result = Glamour.render("")
      refute_nil result
      assert_kind_of String, result
    end

    it "renders multiline markdown" do
      markdown = <<~MD
        # Title

        Paragraph text.

        - Item 1
        - Item 2
      MD
      result = Glamour.render(markdown)
      refute_nil result
      assert_includes result, "Title"
      assert_includes result, "Item"
    end

    it "renders with emoji option" do
      result = Glamour.render("# Hello :wave:", emoji: true)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with preserve_newlines option" do
      result = Glamour.render("Line 1\nLine 2", preserve_newlines: true)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with base_url option" do
      result = Glamour.render("[link](/path)", base_url: "https://example.com")
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with color_profile true_color" do
      result = Glamour.render("# Hello", color_profile: :true_color)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with color_profile ascii" do
      result = Glamour.render("# Hello", color_profile: :ascii)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with json style" do
      json_style = '{"document": {"margin": 2}, "heading": {"bold": true}}'
      result = Glamour.render_with_json("# Hello", json_style)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with json style and width" do
      json_style = '{"document": {"margin": 2}}'
      result = Glamour.render_with_json("# Hello World", json_style, width: 40)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with style hash" do
      style_hash = {
        document: { margin: 2 },
        heading: { bold: true, color: "212" }
      }
      result = Glamour.render_with_style("# Hello", style_hash)
      refute_nil result
      assert_kind_of String, result
      assert_includes result, "Hello"
    end

    it "renders with style json string" do
      json_style = '{"document": {"margin": 2}}'
      result = Glamour.render_with_style("# Hello", json_style)
      refute_nil result
      assert_kind_of String, result
    end

    it "renders with style hash and width" do
      style_hash = { heading: { bold: true } }
      result = Glamour.render_with_style("# Hello World", style_hash, width: 40)
      refute_nil result
      assert_kind_of String, result
    end
  end
end
