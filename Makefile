TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard backboardd


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ActivatePhone

ActivatePhone_FILES = Tweak.x
ActivatePhone_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
