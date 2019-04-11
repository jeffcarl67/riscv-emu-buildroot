################################################################################
#
# kilo
#
################################################################################

KILO_VERSION = af3919d68cb2e70a3d9a2309596cf290cf6bc1ac
KILO_SITE = https://github.com/sysprog21/kilo.git
KILO_SITE_METHOD = git

define KILO_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)"  \
		CFLAGS+="$(TARGET_CFLAGS) "
endef

define KILO_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/kilo $(TARGET_DIR)/usr/bin/kilo
endef

$(eval $(generic-package))
