################################################################################
#
# gcc on target
#
################################################################################

# Version is set when using buildroot toolchain.
# If not, we do like other packages
#ifeq ($(ARCH), riscv64)
#GCC_TARGET2_RISCV=y
#endif
#ifeq ($(ARCH), riscv32)
#GCC_TARGET2_RISCV=y
#endif

#ifeq ($(GCC_TARGET2_RISCV), y)
#GCC_TARGET2_SOURCE = riscv-gcc.tar.gz
#GCC_TARGET2_OVERRIDE_SRCDIR=$(HOME)/riscvemu/riscv-gnu-toolchain/riscv-gcc
#else
GCC_TARGET2_VERSION = $(call qstrip,$(BR2_GCC_VERSION))
GCC_TARGET2_SITE = $(BR2_GNU_MIRROR:/=)/gcc/gcc-$(GCC_VERSION)
GCC_TARGET2_SOURCE ?= gcc-$(GCC_VERSION).tar.xz
#endif

GCC_TARGET2_DEPENDENCIES = gmp mpfr mpc

ifeq ($(GCC_TARGET2_RISCV), y)
GCC_TARGET2_GNU_TARGET_NAME=$(ARCH)-unknown-linux-gnu
else
GCC_TARGET2_GNU_TARGET_NAME=$(GNU_TARGET_NAME)
endif

# XXX: add again c++
GCC_TARGET2_CONF_OPTS = \
	--host=$(GCC_TARGET2_GNU_TARGET_NAME) \
	--target=$(GCC_TARGET2_GNU_TARGET_NAME) \
	--with-sysroot=/ \
	--with-build-sysroot=$(STAGING_DIR) \
	--disable-multilib \
	--disable-bootstrap \
	--disable-__cxa_atexit \
	--disable-libssp \
	--enable-languages=c \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-nls \
        --disable-lto \
	--disable-libmpx \
	--disable-libsanitizer

# XXX: added for riscv, see if it is really necessary
ifneq ($(call qstrip,$(BR2_GCC_TARGET_ARCH)),)
GCC_TARGET2_CONF_OPTS += --with-arch=$(BR2_GCC_TARGET_ARCH)
endif
ifneq ($(call qstrip,$(BR2_GCC_TARGET_ABI)),)
GCC_TARGET2_CONF_OPTS += --with-abi=$(BR2_GCC_TARGET_ABI)
endif

ifeq ($(ARCH), riscv64)
GCC_TARGET2_LIBC_DIR=lib/lp64d
else
GCC_TARGET2_LIBC_DIR=lib
endif

define GCC_TARGET2_INSTALL_HOOK
        cp -r $(STAGING_DIR)/usr/include $(TARGET_DIR)/usr
	mkdir -p $(TARGET_DIR)/usr/$(GCC_TARGET2_LIBC_DIR)
	cp -f $(STAGING_DIR)/usr/$(GCC_TARGET2_LIBC_DIR)/*crt*.o $(TARGET_DIR)/usr/$(GCC_TARGET2_LIBC_DIR)
	cp -f $(STAGING_DIR)/usr/$(GCC_TARGET2_LIBC_DIR)/*_nonshared.a $(TARGET_DIR)/usr/$(GCC_TARGET2_LIBC_DIR)
	for f in libc.so libpthread.so libBrokenLocale.so libnss_nisplus.so libnss_compat.so libnss_hesiod.so libnss_files.so libthread_db.so libbfd.so libnss_dns.so libnss_nis.so libnss_db.so libresolv.so libcrypt.so libcidn.so libutil.so libanl.so libnsl.so libdl.so librt.so libm.so ; do \
	    cp -a $(STAGING_DIR)/usr/$(GCC_TARGET2_LIBC_DIR)/$$f $(TARGET_DIR)/usr/$(GCC_TARGET2_LIBC_DIR) ; \
	done
	rm -f $(TARGET_DIR)/usr/bin/$(ARCH)-buildroot-linux-gnu-*
endef

GCC_TARGET2_POST_INSTALL_TARGET_HOOKS += GCC_TARGET2_INSTALL_HOOK

$(eval $(autotools-package))
