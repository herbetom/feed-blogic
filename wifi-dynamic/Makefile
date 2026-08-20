include $(TOPDIR)/rules.mk

PKG_NAME:=wifi-dynamic
PKG_RELEASE:=1

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/wifi-dynamic
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Configure dynamic wifi instances
  DEPENDS:=+unetmsg
endef

define Package/wifi-dynamic/description
	Spawn (temporary) WiFi interfaces using ubus. The services uses
	procd data for this.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/wifi-dynamic/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,wifi-dynamic))
