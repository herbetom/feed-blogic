include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-gps
PKG_RELEASE:=2

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/ucode-gps
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=NMEA GPS daemon
  DEPENDS:=+ucode +ucode-mod-serial +ucode-mod-io +ucode-mod-ubus +ucode-mod-uloop +ucode-mod-log
  CONFLICTS:=ugps
endef

define Package/ucode-gps/description
	Reads NMEA sentences from a serial port and publishes the position,
	the fix quality and the satellites in view on the `gps` ubus object.
	The object, the method and every key that ugps publishes keep their
	meaning and their type, so the daemon replaces ugps without a change
	on the consumer side. It also adds per constellation counts, the
	satellites in view and the dilution of precision values.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/ucode-gps/conffiles
/etc/config/gps
endef

define Package/ucode-gps/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) ./files/usr/sbin/ucode-gps $(1)/usr/sbin/ucode-gps
	$(INSTALL_BIN) ./files/etc/init.d/ugps $(1)/etc/init.d/ugps
	$(INSTALL_CONF) ./files/etc/config/gps $(1)/etc/config/gps
endef

$(eval $(call BuildPackage,ucode-gps))
