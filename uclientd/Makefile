include $(TOPDIR)/rules.mk

PKG_NAME:=uclientd
PKG_RELEASE:=1

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/uclientd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Client identity and history
  DEPENDS:=+ucode +ucode-mod-ubus +ucode-mod-uloop +ucode-mod-uci +ucode-mod-fs +ufp
endef

define Package/uclientd/description
	Joins the associated stations, the DHCP leases and the ufp fingerprint
	into one record per client, and keeps it in /etc/clients/<mac>.json so a
	device that was here once is still known when it is offline.

	A record is written when its identity changes and not otherwise, and a
	new client is held back until its fingerprint settles, so the flash is
	written a handful of times per device in its life.

	Published on the `clients` ubus object, methods list, get, forget and
	reload.
endef

define Package/uclientd/conffiles
/etc/config/clients
/etc/clients/
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Package/uclientd/install
	$(CP) ./files/* $(1)
	$(INSTALL_DIR) $(1)/etc/clients
endef

$(eval $(call BuildPackage,uclientd))
