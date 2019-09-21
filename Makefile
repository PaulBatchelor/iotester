CHAINPREFIX=mipsel-buildroot-linux-uclibc
CROSS_COMPILE=$(CHAINPREFIX)-

BUILDTIME=$(shell date +'\"%Y-%m-%d %H:%M\"')

CC = $(CROSS_COMPILE)gcc

SYSROOT := $(CHAINPREFIX)/usr/mipsel-buildroot-linux-uclibc/sysroot

CFLAGS = -DTARGET_RETROFW -D__BUILDTIME__="$(BUILDTIME)"
CFLAGS += -DLOG_LEVEL=0 -g0 -Os
CFLAGS += -I$(CHAINPREFIX)/usr/include/
CFLAGS += -I$(SYSROOT)/usr/include/
CFLAGS += -I$(SYSROOT)/usr/include/SDL/
CFLAGS += -mhard-float -mips32 -mno-mips16
CFLAGS += -fdata-sections -ffunction-sections
CFLAGS += -fno-exceptions -fno-math-errno

LDFLAGS = -lfreetype -lSDL_image -lSDL_ttf -lSDL
LDFLAGS += -lpthread
LDFLAGS +=-Wl,--as-needed -Wl,--gc-sections -s

pc:
	gcc iotester.c -g -o iotester -lSDL_image -lSDL -I/usr/include/SDL

retrogame:
	$(CC) $(CFLAGS) $(LDFLAGS) iotester.c -o iotester.dge

ipk: retrogame
	@rm -rf /tmp/.iotester-ipk/ && \
	mkdir -p /tmp/.iotester-ipk/root/home/retrofw/apps/iotester \
	/tmp/.iotester-ipk/root/home/retrofw/apps/gmenu2x/sections/applications
	@cp -r iotester.dge iotester.png backdrop.png /tmp/.iotester-ipk/root/home/retrofw/apps/iotester
	@cp iotester.lnk /tmp/.iotester-ipk/root/home/retrofw/apps/gmenu2x/sections/applications
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" control > /tmp/.iotester-ipk/control
	@tar --owner=0 --group=0 -czvf /tmp/.iotester-ipk/control.tar.gz -C /tmp/.iotester-ipk/ control
	@tar --owner=0 --group=0 -czvf /tmp/.iotester-ipk/data.tar.gz -C /tmp/.iotester-ipk/root/ .
	@echo 2.0 > /tmp/.iotester-ipk/debian-binary
	@ar r iotester.ipk /tmp/.iotester-ipk/control.tar.gz /tmp/.iotester-ipk/data.tar.gz /tmp/.iotester-ipk/debian-binary

clean:
	$(RM) -rf iotester.dge iotester.ipk iotester
