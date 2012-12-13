include $(GNUSTEP_MAKEFILES)/common.make

Cslp_OBJC_FILES = $(wildcard *.m)
ADDITIONAL_FLAGS += -std=gnu99 -fobjc-exceptions -O3

APP_NAME = Cslp
include $(GNUSTEP_MAKEFILES)/application.make

docs:
	sed '1 s/$$/  {#mainpage}/' doc/README.md > doc/mdreadme.md
	doxygen
	rm doc/mdreadme.md
	gimli -f doc/README.md -o doc

	md2man doc/manpage.md > doc/CSLP.1
