include $(GNUSTEP_MAKEFILES)/common.make

files = $(wildcard *.m)

Cslp_OBJC_FILES = $(files)
ADDITIONAL_FLAGS += -std=gnu99 -fobjc-exceptions

APP_NAME = Cslp
include $(GNUSTEP_MAKEFILES)/application.make

LIBRARY_NAME = libCslp
libCslp_OBJC_FILES = $(files)
include $(GNUSTEP_MAKEFILES)/library.make
