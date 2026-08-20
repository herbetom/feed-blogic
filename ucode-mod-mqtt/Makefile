include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-mod-mqtt
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blogic/ucode-mod-mqtt.git
PKG_MIRROR_HASH:=85be129e6b6559f15d3660028a34d919bdc83db9f35a86def3e1c7a9486cb346
PKG_SOURCE_DATE:=2026-08-19
PKG_SOURCE_VERSION:=410335a5de52d0483825e31f5eb0ddf6c0e6d1ee

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ucode-mod-mqtt
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=MQTT module for ucode
  DEPENDS:=+libucode +libmosquitto +libubox
endef

define Package/ucode-mod-mqtt/description
  MQTT client module for ucode using libmosquitto with uloop integration.
  Provides support for multiple concurrent connections, auto-reconnect,
  SSL/TLS, and full MQTT protocol features.
endef

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX=/usr

define Package/ucode-mod-mqtt/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ucode/mqtt.so $(1)/usr/lib/ucode/
endef

$(eval $(call BuildPackage,ucode-mod-mqtt))
