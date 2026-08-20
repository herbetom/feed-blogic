include $(TOPDIR)/rules.mk

PKG_NAME:=umemd
PKG_RELEASE:=1

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/umemd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Per-process memory and fd tracker over ubus
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-ubus +ucode-mod-uloop
endef

define Package/umemd/description
	Samples the RSS and fd count of every process once a minute and keeps
	the minimum of each ten minute window in a two hour history. A rising
	floor is a leak, a plateau is not, so a service that grows after boot
	and then settles returns to stable. Exposes the verdict over the
	`memory` ubus object, split into leaking, stable and warmup buckets.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/umemd/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d
	$(INSTALL_BIN) ./files/usr/sbin/umemd $(1)/usr/sbin/umemd
	$(INSTALL_BIN) ./files/etc/init.d/umemd $(1)/etc/init.d/umemd
endef

$(eval $(call BuildPackage,umemd))
