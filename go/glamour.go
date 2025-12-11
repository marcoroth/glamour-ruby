package main

/*
#include <stdlib.h>
*/
import "C"

import (
	"runtime/debug"
	"unsafe"

	"github.com/charmbracelet/glamour"
	"github.com/muesli/termenv"
)

//export glamour_render
func glamour_render(markdown *C.char, style *C.char) *C.char {
	result, err := glamour.Render(C.GoString(markdown), C.GoString(style))

	if err != nil {
		return C.CString("")
	}

	return C.CString(result)
}

//export glamour_render_with_width
func glamour_render_with_width(markdown *C.char, style *C.char, width C.int) *C.char {
	renderer, err := glamour.NewTermRenderer(
		glamour.WithStylePath(C.GoString(style)),
		glamour.WithWordWrap(int(width)),
	)

	if err != nil {
		return C.CString("")
	}

	result, err := renderer.Render(C.GoString(markdown))

	if err != nil {
		return C.CString("")
	}

	return C.CString(result)
}

//export glamour_render_with_options
func glamour_render_with_options(
	markdown *C.char,
	style *C.char,
	width C.int,
	emoji C.int,
	preserveNewlines C.int,
	baseURL *C.char,
	colorProfile C.int,
) *C.char {
	var options []glamour.TermRendererOption

	styleStr := C.GoString(style)

	if styleStr != "" {
		options = append(options, glamour.WithStylePath(styleStr))
	} else {
		options = append(options, glamour.WithAutoStyle())
	}

	if width > 0 {
		options = append(options, glamour.WithWordWrap(int(width)))
	}

	if emoji != 0 {
		options = append(options, glamour.WithEmoji())
	}

	if preserveNewlines != 0 {
		options = append(options, glamour.WithPreservedNewLines())
	}

	if baseURL != nil {
		baseURLStr := C.GoString(baseURL)

		if baseURLStr != "" {
			options = append(options, glamour.WithBaseURL(baseURLStr))
		}
	}

	// 0=auto, 1=TrueColor, 2=ANSI256, 3=ANSI, 4=Ascii
	switch colorProfile {
	case 1:
		options = append(options, glamour.WithColorProfile(termenv.TrueColor))
	case 2:
		options = append(options, glamour.WithColorProfile(termenv.ANSI256))
	case 3:
		options = append(options, glamour.WithColorProfile(termenv.ANSI))
	case 4:
		options = append(options, glamour.WithColorProfile(termenv.Ascii))
	}

	renderer, err := glamour.NewTermRenderer(options...)

	if err != nil {
		return C.CString("")
	}

	result, err := renderer.Render(C.GoString(markdown))

	if err != nil {
		return C.CString("")
	}

	return C.CString(result)
}

//export glamour_render_with_json_style
func glamour_render_with_json_style(markdown *C.char, jsonStyle *C.char, width C.int) *C.char {
	var options []glamour.TermRendererOption

	jsonBytes := []byte(C.GoString(jsonStyle))
	options = append(options, glamour.WithStylesFromJSONBytes(jsonBytes))

	if width > 0 {
		options = append(options, glamour.WithWordWrap(int(width)))
	}

	renderer, err := glamour.NewTermRenderer(options...)

	if err != nil {
		return C.CString("")
	}

	result, err := renderer.Render(C.GoString(markdown))
	if err != nil {
		return C.CString("")
	}

	return C.CString(result)
}

//export glamour_free
func glamour_free(ptr *C.char) {
	C.free(unsafe.Pointer(ptr))
}

//export glamour_upstream_version
func glamour_upstream_version() *C.char {
	info, ok := debug.ReadBuildInfo()
	if !ok {
		return C.CString("unknown")
	}

	for _, dep := range info.Deps {
		if dep.Path == "github.com/charmbracelet/glamour" {
			return C.CString(dep.Version)
		}
	}

	return C.CString("unknown")
}

func main() {}
