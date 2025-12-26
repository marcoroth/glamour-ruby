/* frozen_string_literal: true */

#include <ruby.h>
#include "libglamour.h"

VALUE mGlamour;
VALUE cRenderer;

#define COLOR_PROFILE_AUTO 0
#define COLOR_PROFILE_TRUE_COLOR 1
#define COLOR_PROFILE_ANSI256 2
#define COLOR_PROFILE_ANSI 3
#define COLOR_PROFILE_ASCII 4

/*
 * Render markdown to terminal-styled output.
 *
 * @param markdown [String] The markdown content to render
 * @param style [String] Style name: "auto", "dark", "light", "notty", "dracula"
 * @param width [Integer] Optional word wrap width
 * @param emoji [Boolean] Enable emoji rendering
 * @param preserve_newlines [Boolean] Preserve newlines in output
 * @param base_url [String] Base URL for relative links
 * @param color_profile [Symbol] Color profile: :auto, :true_color, :ansi256, :ansi, :ascii
 * @return [String] Rendered output with ANSI escape codes
 */
static VALUE glamour_render_rb(int argc, VALUE *argv, VALUE self) {
  VALUE markdown, options;
  rb_scan_args(argc, argv, "1:", &markdown, &options);

  Check_Type(markdown, T_STRING);

  const char *style = "auto";
  const char *base_url = NULL;

  int width = 0;
  int emoji = 0;
  int preserve_newlines = 0;
  int color_profile = COLOR_PROFILE_AUTO;
  int has_advanced_options = 0;

  if (!NIL_P(options)) {
    VALUE style_value = rb_hash_lookup(options, ID2SYM(rb_intern("style")));
    VALUE width_value = rb_hash_lookup(options, ID2SYM(rb_intern("width")));
    VALUE emoji_value = rb_hash_lookup(options, ID2SYM(rb_intern("emoji")));
    VALUE color_value = rb_hash_lookup(options, ID2SYM(rb_intern("color_profile")));

    VALUE base_url_value = rb_hash_lookup(options, ID2SYM(rb_intern("base_url")));
    VALUE preserve_value = rb_hash_lookup(options, ID2SYM(rb_intern("preserve_newlines")));

    if (!NIL_P(style_value)) {
      Check_Type(style_value, T_STRING);
      style = StringValueCStr(style_value);
    }

    if (!NIL_P(width_value)) {
      width = NUM2INT(width_value);
    }

    if (RTEST(emoji_value)) {
      emoji = 1;
      has_advanced_options = 1;
    }

    if (RTEST(preserve_value)) {
      preserve_newlines = 1;
      has_advanced_options = 1;
    }

    if (!NIL_P(base_url_value)) {
      Check_Type(base_url_value, T_STRING);
      base_url = StringValueCStr(base_url_value);
      has_advanced_options = 1;
    }

    if (!NIL_P(color_value)) {
      has_advanced_options = 1;

      if (color_value == ID2SYM(rb_intern("true_color"))) {
        color_profile = COLOR_PROFILE_TRUE_COLOR;
      } else if (color_value == ID2SYM(rb_intern("ansi256"))) {
        color_profile = COLOR_PROFILE_ANSI256;
      } else if (color_value == ID2SYM(rb_intern("ansi"))) {
        color_profile = COLOR_PROFILE_ANSI;
      } else if (color_value == ID2SYM(rb_intern("ascii"))) {
        color_profile = COLOR_PROFILE_ASCII;
      }
    }
  }

  char *result;

  if (has_advanced_options || width > 0) {
    result = glamour_render_with_options(
      (char *) StringValueCStr(markdown),
      (char *) style,
      width,
      emoji,
      preserve_newlines,
      (char *) base_url,
      color_profile
    );
  } else {
    result = glamour_render(
      (char *) StringValueCStr(markdown),
      (char *) style
    );
  }

  VALUE rb_result = rb_utf8_str_new_cstr(result);
  glamour_free(result);

  return rb_result;
}

/*
 * Render markdown with a custom JSON style.
 *
 * @param markdown [String] The markdown content to render
 * @param json_style [String] JSON style definition
 * @param width [Integer] Optional word wrap width
 * @return [String] Rendered output with ANSI escape codes
 */
static VALUE glamour_render_with_json_rb(int argc, VALUE *argv, VALUE self) {
  VALUE markdown, json_style, options;
  rb_scan_args(argc, argv, "2:", &markdown, &json_style, &options);

  Check_Type(markdown, T_STRING);
  Check_Type(json_style, T_STRING);

  int width = 0;

  if (!NIL_P(options)) {
    VALUE width_value = rb_hash_lookup(options, ID2SYM(rb_intern("width")));

    if (!NIL_P(width_value)) {
      width = NUM2INT(width_value);
    }
  }

  char *result = glamour_render_with_json_style(
    (char *) StringValueCStr(markdown),
    (char *) StringValueCStr(json_style),
    width
  );

  VALUE rb_result = rb_utf8_str_new_cstr(result);
  glamour_free(result);

  return rb_result;
}

/*
 * Get the upstream glamour version.
 *
 * @return [String] Upstream glamour version
 */
static VALUE glamour_upstream_version_rb(VALUE self) {
  char *version = glamour_upstream_version();
  VALUE rb_version = rb_utf8_str_new_cstr(version);
  glamour_free(version);

  return rb_version;
}

/*
 * Get the glamour version info.
 *
 * @return [String] Version information string
 */
static VALUE glamour_version_rb(VALUE self) {
  VALUE gem_version = rb_const_get(self, rb_intern("VERSION"));
  VALUE upstream_version = glamour_upstream_version_rb(self);
  VALUE format_string = rb_utf8_str_new_cstr("glamour v%s (upstream %s) [Go native extension]");

  return rb_funcall(rb_mKernel, rb_intern("sprintf"), 3, format_string, gem_version, upstream_version);
}

/* Renderer class methods */

static VALUE renderer_alloc(VALUE klass) {
  return Data_Wrap_Struct(klass, NULL, NULL, NULL);
}

static VALUE renderer_initialize(int argc, VALUE *argv, VALUE self) {
  VALUE options;
  rb_scan_args(argc, argv, "0:", &options);

  rb_iv_set(self, "@style", rb_str_new_cstr("auto"));
  rb_iv_set(self, "@width", INT2FIX(0));
  rb_iv_set(self, "@emoji", Qfalse);
  rb_iv_set(self, "@preserve_newlines", Qfalse);
  rb_iv_set(self, "@base_url", Qnil);
  rb_iv_set(self, "@color_profile", ID2SYM(rb_intern("auto")));
  rb_iv_set(self, "@json_style", Qnil);

  if (!NIL_P(options)) {
    VALUE style = rb_hash_lookup(options, ID2SYM(rb_intern("style")));
    if (!NIL_P(style)) rb_iv_set(self, "@style", style);

    VALUE width = rb_hash_lookup(options, ID2SYM(rb_intern("width")));
    if (!NIL_P(width)) rb_iv_set(self, "@width", width);

    VALUE emoji = rb_hash_lookup(options, ID2SYM(rb_intern("emoji")));
    if (RTEST(emoji)) rb_iv_set(self, "@emoji", Qtrue);

    VALUE preserve = rb_hash_lookup(options, ID2SYM(rb_intern("preserve_newlines")));
    if (RTEST(preserve)) rb_iv_set(self, "@preserve_newlines", Qtrue);

    VALUE base_url = rb_hash_lookup(options, ID2SYM(rb_intern("base_url")));
    if (!NIL_P(base_url)) rb_iv_set(self, "@base_url", base_url);

    VALUE color = rb_hash_lookup(options, ID2SYM(rb_intern("color_profile")));
    if (!NIL_P(color)) rb_iv_set(self, "@color_profile", color);

    VALUE json = rb_hash_lookup(options, ID2SYM(rb_intern("json_style")));
    if (!NIL_P(json)) rb_iv_set(self, "@json_style", json);
  }

  return self;
}

static VALUE renderer_render(VALUE self, VALUE markdown) {
  Check_Type(markdown, T_STRING);

  VALUE json_style = rb_iv_get(self, "@json_style");

  if (!NIL_P(json_style)) {
    int width = NUM2INT(rb_iv_get(self, "@width"));

    char *result = glamour_render_with_json_style(
      (char *)StringValueCStr(markdown),
      (char *)StringValueCStr(json_style),
      width
    );

    VALUE rb_result = rb_utf8_str_new_cstr(result);
    glamour_free(result);
    return rb_result;
  }

  VALUE style_value = rb_iv_get(self, "@style");
  const char *style = NIL_P(style_value) ? "auto" : StringValueCStr(style_value);
  int width = NUM2INT(rb_iv_get(self, "@width"));
  int emoji = RTEST(rb_iv_get(self, "@emoji")) ? 1 : 0;
  int preserve_newlines = RTEST(rb_iv_get(self, "@preserve_newlines")) ? 1 : 0;

  VALUE base_url_value = rb_iv_get(self, "@base_url");
  const char *base_url = NIL_P(base_url_value) ? NULL : StringValueCStr(base_url_value);

  VALUE color_value = rb_iv_get(self, "@color_profile");
  int color_profile = COLOR_PROFILE_AUTO;

  if (color_value == ID2SYM(rb_intern("true_color"))) {
    color_profile = COLOR_PROFILE_TRUE_COLOR;
  } else if (color_value == ID2SYM(rb_intern("ansi256"))) {
    color_profile = COLOR_PROFILE_ANSI256;
  } else if (color_value == ID2SYM(rb_intern("ansi"))) {
    color_profile = COLOR_PROFILE_ANSI;
  } else if (color_value == ID2SYM(rb_intern("ascii"))) {
    color_profile = COLOR_PROFILE_ASCII;
  }

  char *result = glamour_render_with_options(
    (char *)StringValueCStr(markdown),
    (char *)style,
    width,
    emoji,
    preserve_newlines,
    (char *)base_url,
    color_profile
  );

  VALUE rb_result = rb_utf8_str_new_cstr(result);
  glamour_free(result);

  return rb_result;
}

__attribute__((__visibility__("default"))) void Init_glamour(void) {
  mGlamour = rb_define_module("Glamour");

  rb_define_singleton_method(mGlamour, "render", glamour_render_rb, -1);
  rb_define_singleton_method(mGlamour, "render_with_json", glamour_render_with_json_rb, -1);
  rb_define_singleton_method(mGlamour, "upstream_version", glamour_upstream_version_rb, 0);
  rb_define_singleton_method(mGlamour, "version", glamour_version_rb, 0);

  cRenderer = rb_define_class_under(mGlamour, "Renderer", rb_cObject);
  rb_define_alloc_func(cRenderer, renderer_alloc);
  rb_define_method(cRenderer, "initialize", renderer_initialize, -1);
  rb_define_method(cRenderer, "render", renderer_render, 1);

  rb_define_attr(cRenderer, "style", 1, 1);
  rb_define_attr(cRenderer, "width", 1, 1);
  rb_define_attr(cRenderer, "emoji", 1, 1);
  rb_define_attr(cRenderer, "preserve_newlines", 1, 1);
  rb_define_attr(cRenderer, "base_url", 1, 1);
  rb_define_attr(cRenderer, "color_profile", 1, 1);
  rb_define_attr(cRenderer, "json_style", 1, 1);
}
