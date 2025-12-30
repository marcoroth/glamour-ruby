<div align="center">
  <h1>Glamour for Ruby</h1>
  <h4>Stylesheet-based markdown rendering for your CLI apps.</h4>

  <p>
    <a href="https://rubygems.org/gems/glamour"><img alt="Gem Version" src="https://img.shields.io/gem/v/glamour"></a>
    <a href="https://github.com/marcoroth/glamour-ruby/blob/main/LICENSE.txt"><img alt="License" src="https://img.shields.io/github/license/marcoroth/glamour-ruby"></a>
  </p>

  <p>Ruby bindings for <a href="https://github.com/charmbracelet/glamour">charmbracelet/glamour</a>.<br/>Render markdown documents & templates on ANSI compatible terminals.</p>
</div>

## Installation

**Add to your Gemfile:**

```ruby
gem "glamour"
```

**Or install directly:**

```bash
gem install glamour
```

## Usage

### Basic Rendering

**Render markdown with auto-detected style:**

```ruby
require "glamour"

puts Glamour.render("# Hello World")
```

**Render with a specific style:**

```ruby
puts Glamour.render("# Hello", style: "dark")
puts Glamour.render("# Hello", style: "light")
puts Glamour.render("# Hello", style: "dracula")
puts Glamour.render("# Hello", style: "notty")
```

**Render with word wrap:**

```ruby
puts Glamour.render(long_markdown, width: 80)
```

### Render Options

| Option | Description |
|--------|-------------|
| `style` | `"auto"`, `"dark"`, `"light"`, `"notty"`, `"dracula"` |
| `width` | Word wrap width |
| `emoji` | Enable emoji rendering (`:wave:` → 👋) |
| `preserve_newlines` | Preserve newlines in output |
| `base_url` | Base URL for relative links |
| `color_profile` | `:auto`, `:true_color`, `:ansi256`, `:ansi`, `:ascii` |

**Example with all options:**

```ruby
Glamour.render(markdown,
  style: "dark",
  width: 80,
  emoji: true,
  preserve_newlines: true,
  base_url: "https://example.com",
  color_profile: :true_color
)
```

### Custom Styles with Hash

**Define a custom style:**

```ruby
custom_style = {
  heading: { bold: true, color: "212" },
  strong: { bold: true, color: "196" },
  emph: { italic: true, color: "226" },
  code: { color: "203", background_color: "236" }
}
```

**Render with the custom style:**

```ruby
Glamour.render_with_style("# Hello **World**", custom_style)
```

**With width option:**

```ruby
Glamour.render_with_style("# Hello", custom_style, width: 60)
```

### Style DSL

**Define reusable styles using a Ruby DSL:**

```ruby
class MyStyle < Glamour::Style
  style :heading do
    bold true
    color "212"
  end

  style :h1 do
    prefix "# "
    color "99"
    bold true
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

  style :document do
    margin 2
  end
end
```

**Use the style class directly:**

```ruby
MyStyle.render("# Hello **World**")
MyStyle.render("# Hello", width: 80)
```

**Or pass to Glamour.render:**

```ruby
Glamour.render("# Hello", style: MyStyle)
```

### Reusable Renderer

**Create a renderer with preset options:**

```ruby
renderer = Glamour::Renderer.new(
  style: "dark",
  width: 80,
  emoji: true
)
```

**Render multiple documents:**

```ruby
puts renderer.render("# Hello :wave:")
puts renderer.render("# Another document")
```

**With a Style class:**

```ruby
renderer = Glamour::Renderer.new(style: MyStyle, width: 60)
puts renderer.render("# Styled output")
```

## Available Style Elements

### Block Elements

| Element | Description |
|---------|-------------|
| `document` | Root document wrapper |
| `paragraph` | Text paragraphs |
| `heading` | Base heading style (h1-h6 inherit from this) |
| `h1` - `h6` | Individual heading levels |
| `block_quote` | Block quotations |
| `code_block` | Fenced code blocks |
| `list` | List containers |
| `item` | List items (bullets) |
| `enumeration` | Numbered list items |
| `table` | Markdown tables |
| `hr` | Horizontal rules |

### Inline Elements

| Element | Description |
|---------|-------------|
| `text` | Base text styling |
| `strong` | Bold text (`**bold**`) |
| `emph` | Italic text (`*italic*`) |
| `strikethrough` | Strikethrough text |
| `code` | Inline code (`` `code` ``) |
| `link` | Link elements |
| `link_text` | Link text display |
| `image` | Image references |

## Style Properties

**Text decoration:**

```ruby
bold true
italic true
underline true
crossed_out true
faint true
inverse true
overlined true
```

**Colors (ANSI 256 color codes):**

```ruby
color "212"
background_color "236"
```

**Spacing:**

```ruby
margin 2
indent 1
indent_token "  "
level_indent 2
```

**Prefix/suffix:**

```ruby
prefix "# "
suffix ""
block_prefix ""
block_suffix "\n"
```

## Built-in Styles

- `"auto"` - Auto-detect dark/light terminal
- `"dark"` - Dark terminal theme
- `"light"` - Light terminal theme
- `"notty"` - No colors (for non-TTY output)
- `"dracula"` - Dracula color scheme

## Version Info

```ruby
puts Glamour.version
```

## Development

**Requirements:**
- Go 1.23+
- Ruby 3.2+

**Install dependencies:**

```bash
bundle install
```

**Build the Go library and compile the extension:**

```bash
bundle exec rake compile
```

**Run tests:**

```bash
bundle exec rake test
```

**Run demos:**

```bash
./demo/basic
./demo/styles
./demo/style_dsl
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcoroth/glamour-ruby.

## License

The gem is available as open source under the terms of the MIT License.

## Acknowledgments

This gem wraps [charmbracelet/glamour](https://github.com/charmbracelet/glamour), part of the excellent [Charm](https://charm.sh) ecosystem. Charm Ruby is not affiliated with or endorsed by Charmbracelet, Inc.

---

Part of [Charm Ruby](https://charm-ruby.dev).

<a href="https://charm-ruby.dev"><img alt="Charm Ruby" src="https://marcoroth.dev/images/heros/glamorous-christmas.png" width="400"></a>

[Lipgloss](https://github.com/marcoroth/lipgloss-ruby) • [Bubble Tea](https://github.com/marcoroth/bubbletea-ruby) • [Bubbles](https://github.com/marcoroth/bubbles-ruby) • [Glamour](https://github.com/marcoroth/glamour-ruby) • [Huh?](https://github.com/marcoroth/huh-ruby) • [Harmonica](https://github.com/marcoroth/harmonica-ruby) • [Bubblezone](https://github.com/marcoroth/bubblezone-ruby) • [Gum](https://github.com/marcoroth/gum-ruby) • [ntcharts](https://github.com/marcoroth/ntcharts-ruby)

The terminal doesn't have to be boring.
