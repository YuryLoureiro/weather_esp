# Copyright (c) 2023 John Graham-Cumming

include gmsl

.PHONY: all
all:

# Used to build the PNG versions of SVG weather icons in the sizes
# needed by the eink-weather project. The original icons come from
#
# https://erikflowers.github.io/weather-icons/
#
# List of icon widths (in pixels) that are to be created. For each
# .svg file .png versions are created with the width appended. For
# example, rain.svg could become rain-24.png, rain-128.png etc.
#

WIDTHS := 43 128

# This builds the Adafruit fontconvert executable needed to convert
# fonts to the GFX format

CC     := gcc
CFLAGS := -Wall -I/usr/local/include/freetype2 -I/usr/include/freetype2 -I/usr/include
LIBS   := -lfreetype

fontconvert: fontconvert.c gfxfont.h
	@$(CC) $(CFLAGS) $< $(LIBS) -o $@
	@strip $@

# This section converts the Roboto fonts from TTF to GFX format needed
# by the project. Note that we specify an extended range of glyphs
# because the default does not include the degree symbol.

FONTS_DIR := fonts/
GFX_DIR := $(FONTS_DIR)gfx/
TTF_DIR := $(FONTS_DIR)ttf/

$(shell mkdir -p $(GFX_DIR))

FONTS := Roboto_Bold_12 Roboto_Regular_7 Roboto_Regular_10 Roboto_Regular_24

H_FILES := $(addprefix $(GFX_DIR),$(addsuffix .h,$(FONTS)))

font-name = $(subst $(GFX_DIR),$(TTF_DIR),$(word 1,$(call split,_,$(subst .h,,$1)))-$(word 2,$(call split,_,$(subst .h,,$1)))).ttf
font-size = $(lastword $(call split,_,$(subst .h,,$1)))
$(foreach f,$(H_FILES),$(eval $f: $(call font-name,$f) ; @./fontconvert $$< $(call font-size,$f) 32 255 > $$@))

$(H_FILES): fontconvert
all: $(H_FILES)

# clean deletes all created files

.PHONY: clean
clean: ; @rm -f $(PNGS) fontconvert $(H_FILES)

