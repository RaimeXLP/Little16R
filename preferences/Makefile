ARCHS = arm64
TARGET = iphone:clang:latest:15.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Little16RPrefs
Little16RPrefs_FILES = L16RRootListController.m
Little16RPrefs_FRAMEWORKS = UIKit Foundation CoreFoundation
Little16RPrefs_PRIVATE_FRAMEWORKS = Preferences
Little16RPrefs_INSTALL_PATH = /Library/PreferenceBundles
Little16RPrefs_CFLAGS = -fobjc-arc -Wall -Wextra
ifneq ($(strip $(LITTLE16R_PRIVATE_FRAMEWORKS_DIR)),)
Little16RPrefs_LDFLAGS += -F$(LITTLE16R_PRIVATE_FRAMEWORKS_DIR)
endif

include $(THEOS_MAKE_PATH)/bundle.mk
