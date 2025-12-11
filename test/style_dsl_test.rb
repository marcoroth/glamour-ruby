# frozen_string_literal: true

require_relative "test_helper"

module Glamour
  class StyleDefinitionTest < Minitest::Spec
    it "defines basic attributes" do
      definition = Glamour::StyleDefinition.new do
        bold true
        color "212"
      end

      assert_equal({ bold: true, color: "212" }, definition.to_h)
    end

    it "defines nested attributes" do
      definition = Glamour::StyleDefinition.new do
        chroma do
          keyword do
            color "170"
            bold true
          end
        end
      end

      expected = {
        chroma: {
          keyword: {
            color: "170",
            bold: true
          }
        }
      }
      assert_equal(expected, definition.to_h)
    end
  end

  class StyleTest < Minitest::Spec
    it "defines a style for an element" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
          color "212"
        end
      end

      assert_equal({ "heading" => { bold: true, color: "212" } }, klass.to_h)
    end

    it "defines multiple elements" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
          color "212"
        end

        style :strong do
          bold true
          color "196"
        end

        style :emph do
          italic true
          color "226"
        end
      end

      expected = {
        "heading" => { bold: true, color: "212" },
        "strong" => { bold: true, color: "196" },
        "emph" => { italic: true, color: "226" }
      }
      assert_equal(expected, klass.to_h)
    end

    it "converts to json" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
        end
      end

      json = klass.to_json
      assert_kind_of String, json
      parsed = JSON.parse(json)
      assert_equal({ "heading" => { "bold" => true } }, parsed)
    end

    it "responds to glamour_style?" do
      klass = Class.new(Glamour::Style)
      assert klass.glamour_style?
    end

    it "renders markdown" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
          color "212"
        end
      end

      result = klass.render("# Hello")
      refute_nil result
      assert_kind_of String, result
      assert_includes result, "Hello"
    end

    it "renders with width option" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
        end
      end

      result = klass.render("# Hello World", width: 40)
      refute_nil result
      assert_kind_of String, result
    end

    it "handles empty style class" do
      klass = Class.new(Glamour::Style)

      assert_equal({}, klass.to_h)
      assert_equal "{}", klass.to_json
    end

    it "accepts a Style class in Glamour.render" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
          color "99"
        end
      end

      result = Glamour.render("# Hello", style: klass)
      refute_nil result
      assert_kind_of String, result
      assert_includes result, "Hello"
    end

    it "accepts a Style class with width in Glamour.render" do
      klass = Class.new(Glamour::Style) do
        style :heading do
          bold true
        end
      end

      result = Glamour.render("# Hello World", style: klass, width: 40)
      refute_nil result
      assert_kind_of String, result
    end

    it "accepts a Style class in Glamour.render_with_style" do
      klass = Class.new(Glamour::Style) do
        style :strong do
          bold true
          color "196"
        end
      end

      result = Glamour.render_with_style("**bold**", klass)
      refute_nil result
      assert_kind_of String, result
    end

    it "supports all text decorations" do
      klass = Class.new(Glamour::Style) do
        style :text do
          bold true
          italic true
          underline true
          crossed_out true
          faint true
          inverse true
          overlined true
        end
      end

      expected_keys = %i[bold italic underline crossed_out faint inverse overlined]
      expected_keys.each do |key|
        assert klass.to_h["text"].key?(key), "Expected #{key} to be present"
        assert_equal true, klass.to_h["text"][key]
      end
    end

    it "supports colors" do
      klass = Class.new(Glamour::Style) do
        style :code do
          color "203"
          background_color "236"
        end
      end

      assert_equal "203", klass.to_h["code"][:color]
      assert_equal "236", klass.to_h["code"][:background_color]
    end

    it "supports spacing" do
      klass = Class.new(Glamour::Style) do
        style :document do
          margin 2
          block_prefix ""
          block_suffix "\n"
        end
      end

      assert_equal 2, klass.to_h["document"][:margin]
      assert_equal "", klass.to_h["document"][:block_prefix]
      assert_equal "\n", klass.to_h["document"][:block_suffix]
    end

    it "supports prefix and suffix" do
      klass = Class.new(Glamour::Style) do
        style :h1 do
          prefix "# "
          bold true
        end
      end

      assert_equal "# ", klass.to_h["h1"][:prefix]
      assert_equal true, klass.to_h["h1"][:bold]
    end

    it "renders with a comprehensive style definition" do
      klass = Class.new(Glamour::Style) do
        style :document do
          margin 2
        end

        style :heading do
          bold true
          color "39"
        end

        style :h1 do
          prefix "# "
          color "212"
          bold true
        end

        style :paragraph do
          block_prefix ""
          block_suffix ""
        end

        style :strong do
          bold true
          color "196"
        end

        style :emph do
          italic true
          color "226"
        end

        style :code do
          color "203"
          background_color "236"
        end
      end

      result = klass.render(<<~MD)
        # Hello World

        This is **bold** and *italic*.

        Some `inline code` too.
      MD

      refute_nil result
      assert_kind_of String, result
    end
  end
end
