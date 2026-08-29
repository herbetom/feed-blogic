include $(TOPDIR)/rules.mk

PKG_NAME:=udeviced
PKG_RELEASE:=1

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/udeviced
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Device throughput and health sampler
  DEPENDS:=+ucode +ucode-mod-ubus +ucode-mod-uloop +ucode-mod-uci +ucode-mod-fs
endef

define Package/udeviced/description
	Samples the WAN counters, the CPU, the memory, the flash and the
	temperature once a second, and keeps the throughput in four steps: 120
	seconds, an hour of minutes, a day of hours and a month of days. The
	history lives in RAM and nothing is written to flash.

	Configured in the `monitoring` section of /etc/config/system, seeded by
	a uci-defaults script that probes the hwmon inputs.

	Published on the `device` ubus object, methods status, history and
	reload.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/udeviced/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,udeviced))
