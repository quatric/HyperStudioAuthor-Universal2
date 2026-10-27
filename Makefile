# Builds HyperStudio 5.2 as a Universal 2 (arm64 + x86_64) app from the
# translated sources in src/, with the original resources from game/.
#
#   make            build every framework (untranslated methods are stubs that
#                   log once: HS_UNTRANSLATED())
#   make progress   count translated and untranslated methods
#   make clean

ARCHS    := -arch arm64 -arch x86_64
MINOS    := -mmacosx-version-min=11.0
CC       := clang
WARN     := -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function \
            -Wno-objc-method-access -Wno-incomplete-implementation -Wno-unused-but-set-variable -Wno-objc-designated-initializers
CFLAGS   := $(ARCHS) $(MINOS) -g -O1 -fno-objc-arc -fobjc-exceptions $(WARN) -MMD -MP \
            -DGL_SILENCE_DEPRECATION -Isrc/Common -Isrc/HSQTKit
LDFLAGS  := $(ARCHS) $(MINOS)
OBJ      := build/obj
BIN      := build/bin

COMMON_OBJ := $(OBJ)/Common/HSTranslate.m.o

# framework name, install name, frameworks it links, system frameworks
define framework
$(1)_SRC := $$(wildcard src/$(1)/*.m src/$(1)/*.mm src/$(1)/*.c src/$(1)/*.cpp)
$(1)_OBJ := $$(patsubst src/%,$(OBJ)/%.o,$$($(1)_SRC))
$(1)_PREFIX ?= -include src/$(1)/$(1)Prefix.h
$$($(1)_OBJ): CFLAGS += -Isrc/$(1) $(foreach d,$(3),-Isrc/$(d)) $$($(1)_PREFIX)
$(BIN)/$(1): $$($(1)_OBJ) $(COMMON_OBJ) $(foreach d,$(3),$(BIN)/$(d))
	@mkdir -p $$(@D)
	$(CC) $(LDFLAGS) -dynamiclib -install_name $(2) -o $$@ $$($(1)_OBJ) $(COMMON_OBJ) \
		$(foreach d,$(3),$(BIN)/$(d)) $(foreach f,$(4),-framework $(f)) -lz -lc++
all: $(BIN)/$(1)
endef

SYSFW := Cocoa Carbon Quartz QuartzCore AVFoundation AVKit CoreMedia CoreVideo VideoToolbox AudioToolbox \
         AudioUnit CoreAudio OpenGL Accelerate IOKit Security SystemConfiguration WebKit \
         UniformTypeIdentifiers

all:

$(eval $(call framework,HSQTKit,@rpath/HSQTKit.framework/Versions/A/HSQTKit,,Cocoa AVFoundation AVKit CoreMedia CoreVideo VideoToolbox QuartzCore UniformTypeIdentifiers))
$(eval $(call framework,SMKApplicationKit,@loader_path/../Frameworks/SMKApplicationKit.framework/Versions/C-10-4/SMKApplicationKit,HSQTKit,$(SYSFW)))
$(eval $(call framework,SMKBitmapTools,@loader_path/../Frameworks/SMKBitmapTools.framework/Versions/A-10-4/SMKBitmapTools,SMKApplicationKit HSQTKit,$(SYSFW)))
# SMKControls: the Weather Globe Deluxe port's translation (version 211) patched
# to this build (217); every source gets the umbrella header, as the original's
# prefix header gave it the whole framework.
$(eval $(call framework,SMKControls,@executable_path/../Frameworks/SMKControls.framework/Versions/A/SMKControls,,Cocoa CoreServices))
$(SMKControls_OBJ): CFLAGS += -include src/SMKControls/SMKControlsUmbrella.h
# SMKCheckForUpdates: MacKiev's update check (the service is gone), a stub.
$(eval $(call framework,SMKCheckForUpdates,@loader_path/../Frameworks/SMKCheckForUpdates.framework/Versions/B/SMKCheckForUpdates,,Foundation))
# SMKPublish: the publishing (remote data objects) framework; every source
# gets the umbrella header, as with SMKControls.
$(eval $(call framework,SMKPublish,@executable_path/../Frameworks/SMKPublish.framework/Versions/A/SMKPublish,,Cocoa))
$(SMKPublish_OBJ): CFLAGS += -include src/SMKPublish/SMKPublishUmbrella.h
# HyperPlayerBase: every source sees the whole framework (prefix + umbrella),
# so it comes from a precompiled header, one per architecture.
HPB_PCH := $(OBJ)/pch/HyperPlayerBase
HPB_PCHFLAGS := $(MINOS) -g -O1 -fno-objc-arc -fobjc-exceptions $(WARN) -Wno-protocol -MMD -MP \
                -DGL_SILENCE_DEPRECATION -Isrc/Common -Isrc/HSQTKit -Isrc/HyperPlayerBase \
                -Isrc/SMKApplicationKit -Isrc/SMKBitmapTools -Isrc/SMKCheckForUpdates
HyperPlayerBase_PREFIX :=
$(HPB_PCH)-%.pch: src/HyperPlayerBase/HyperPlayerBasePCH.h
	@mkdir -p $(@D)
	$(CC) -arch $* $(HPB_PCHFLAGS) -x objective-c-header $< -o $@
# (a PCH is per architecture and -Xarch_ can't pass -include-pch: each
# architecture is compiled on its own, then the objects are joined)
$(OBJ)/HyperPlayerBase/%.m.o: src/HyperPlayerBase/%.m
	@mkdir -p $(@D)
	$(CC) -arch arm64 $(HPB_PCHFLAGS) -MF $(@:.o=.d) -MT $@ -include-pch $(HPB_PCH)-arm64.pch -c $< -o $@.arm64
	$(CC) -arch x86_64 $(filter-out -MMD -MP,$(HPB_PCHFLAGS)) -include-pch $(HPB_PCH)-x86_64.pch -c $< -o $@.x86_64
	lipo -create $@.arm64 $@.x86_64 -output $@ && rm -f $@.arm64 $@.x86_64
$(eval $(call framework,HyperPlayerBase,@loader_path/../Frameworks/HyperPlayerBase.framework/Versions/A/HyperPlayerBase,SMKApplicationKit SMKBitmapTools SMKCheckForUpdates HSQTKit,$(SYSFW) OSAKit PreferencePanes))
# stub classes adopt protocols their (translated or not) superclasses implement
$(HyperPlayerBase_OBJ): CFLAGS += -Wno-protocol
$(HyperPlayerBase_OBJ): $(HPB_PCH)-arm64.pch $(HPB_PCH)-x86_64.pch

# HyperEditorBase: the same precompiled prefix + umbrella scheme.
HEB_PCH := $(OBJ)/pch/HyperEditorBase
HEB_PCHFLAGS := $(MINOS) -g -O1 -fno-objc-arc -fobjc-exceptions $(WARN) -Wno-protocol -MMD -MP \
                -DGL_SILENCE_DEPRECATION -Isrc/Common -Isrc/HSQTKit -Isrc/HyperEditorBase -Isrc/HyperPlayerBase \
                -Isrc/SMKApplicationKit -Isrc/SMKBitmapTools -Isrc/SMKCheckForUpdates -Isrc/SMKControls
HyperEditorBase_PREFIX :=
$(HEB_PCH)-%.pch: src/HyperEditorBase/HyperEditorBasePCH.h
	@mkdir -p $(@D)
	$(CC) -arch $* $(HEB_PCHFLAGS) -x objective-c-header $< -o $@
$(OBJ)/HyperEditorBase/%.m.o: src/HyperEditorBase/%.m
	@mkdir -p $(@D)
	$(CC) -arch arm64 $(HEB_PCHFLAGS) -MF $(@:.o=.d) -MT $@ -include-pch $(HEB_PCH)-arm64.pch -c $< -o $@.arm64
	$(CC) -arch x86_64 $(filter-out -MMD -MP,$(HEB_PCHFLAGS)) -include-pch $(HEB_PCH)-x86_64.pch -c $< -o $@.x86_64
	lipo -create $@.arm64 $@.x86_64 -output $@ && rm -f $@.arm64 $@.x86_64
$(eval $(call framework,HyperEditorBase,@loader_path/../Frameworks/HyperEditorBase.framework/Versions/A/HyperEditorBase,HyperPlayerBase SMKControls SMKApplicationKit SMKBitmapTools SMKCheckForUpdates HSQTKit,$(SYSFW) OSAKit AddressBook))
$(HyperEditorBase_OBJ): $(HEB_PCH)-arm64.pch $(HEB_PCH)-x86_64.pch

# HyperStudio: the editor application, built like HyperEditorBase (one
# precompiled prefix + umbrella per architecture) but linked as an executable.
HS_PCH := $(OBJ)/pch/HyperStudio
HS_PCHFLAGS := $(MINOS) -g -O1 -fno-objc-arc -fobjc-exceptions $(WARN) -Wno-protocol -MMD -MP \
               -DGL_SILENCE_DEPRECATION -Isrc/Common -Isrc/HSQTKit -Isrc/HyperStudio -Isrc/HyperEditorBase \
               -Isrc/HyperPlayerBase -Isrc/SMKApplicationKit -Isrc/SMKBitmapTools -Isrc/SMKCheckForUpdates \
               -Isrc/SMKControls -Isrc/SMKPublish
HS_FRAMEWORKS := HyperEditorBase HyperPlayerBase SMKPublish SMKControls SMKApplicationKit SMKBitmapTools \
                 SMKCheckForUpdates HSQTKit
HyperStudio_SRC := $(wildcard src/HyperStudio/*.m src/HyperStudio/*.c)
HyperStudio_OBJ := $(patsubst src/%,$(OBJ)/%.o,$(HyperStudio_SRC))
$(HS_PCH)-%.pch: src/HyperStudio/HyperStudioPCH.h
	@mkdir -p $(@D)
	$(CC) -arch $* $(HS_PCHFLAGS) -x objective-c-header $< -o $@
$(OBJ)/HyperStudio/%.m.o: src/HyperStudio/%.m
	@mkdir -p $(@D)
	$(CC) -arch arm64 $(HS_PCHFLAGS) -MF $(@:.o=.d) -MT $@ -include-pch $(HS_PCH)-arm64.pch -c $< -o $@.arm64
	$(CC) -arch x86_64 $(filter-out -MMD -MP,$(HS_PCHFLAGS)) -include-pch $(HS_PCH)-x86_64.pch -c $< -o $@.x86_64
	lipo -create $@.arm64 $@.x86_64 -output $@ && rm -f $@.arm64 $@.x86_64
$(HyperStudio_OBJ): $(HS_PCH)-arm64.pch $(HS_PCH)-x86_64.pch
$(BIN)/HyperStudio: $(HyperStudio_OBJ) $(COMMON_OBJ) $(foreach d,$(HS_FRAMEWORKS),$(BIN)/$(d))
	@mkdir -p $(@D)
	$(CC) $(LDFLAGS) -o $@ $(HyperStudio_OBJ) $(COMMON_OBJ) $(foreach d,$(HS_FRAMEWORKS),$(BIN)/$(d)) \
		$(foreach f,$(SYSFW) OSAKit AddressBook CoreData,-framework $(f)) -lz -lc++
all: $(BIN)/HyperStudio

$(OBJ)/%.m.o: src/%.m
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OBJ)/%.mm.o: src/%.mm
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -std=gnu++17 -c $< -o $@
$(OBJ)/%.c.o: src/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OBJ)/%.cpp.o: src/%.cpp
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -std=gnu++17 -c $< -o $@

-include $(shell find $(OBJ) -name '*.d' 2>/dev/null)

progress:
	@python3 -I tools/progress.py

clean:
	rm -rf $(OBJ) $(BIN)

.PHONY: all progress clean
