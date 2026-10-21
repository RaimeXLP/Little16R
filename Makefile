ARCHS = arm64
TARGET = iphone:clang:latest:15.0
FINALPACKAGE = 1
INSTALL_TARGET_PROCESSES = SpringBoard

# This project intentionally targets the legacy rootful layout.
ifneq ($(strip $(THEOS_PACKAGE_SCHEME)),)
$(error Build with THEOS_PACKAGE_SCHEME unset; Little16R targets rootful only)
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Little16R
Little16R_FILES = Tweak.m SurfaceHomebar.m
Little16R_CFLAGS = -fobjc-arc -Wall -Wextra
Little16R_FRAMEWORKS = Foundation UIKit CoreFoundation QuartzCore
Little16R_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
