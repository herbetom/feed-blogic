#
# Copyright (C) 2026 John Crispin <john@phrozen.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-mdns
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blogic/ucode-mdns.git
PKG_MIRROR_HASH:=8254e3765d8f4175abd2bd51e3b20ff3084d15a606044f9bf801befa9dd5086e
PKG_SOURCE_DATE:=2026-08-19
PKG_SOURCE_VERSION:=7edb96b392d19080fa1a7942bfda9cab891684bc

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package-seccomp.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_INSTALL:=1

define Package/ucode-mdns
  SECTION:=net
  CATEGORY:=Network
  TITLE:=mDNS responder and service browser in ucode
  URL:=https://github.com/blogic/ucode-mdns
  DEPENDS:=+ucode-mod-uloop +ucode-mod-ubus +ucode-mod-uci \
	   +ucode-mod-fs +ucode-mod-log +ucode-mod-math
  PROVIDES:=umdns mdns-daemon
endef

define Package/ucode-mdns/description
An RFC 6762 and RFC 6763 responder and browser. A small C module owns the
wire and the kernel, the protocol logic lives in ucode. It replaces umdns:
the ubus object, the method names, the UCI schema and the service files in
/etc/umdns keep their meaning, so the cli module and the LuCI pages need no
change.
endef

define Package/ucode-mdns/conffiles
/etc/config/umdns
endef

define Package/ucode-mdns/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode $(1)/usr/share/umdnsd \
		$(1)/etc/init.d $(1)/etc/config $(1)/etc/umdns \
		$(1)/usr/share/ucode/cli/modules $(1)/usr/share/rpcd/acl.d
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ucode/mdns.so $(1)/usr/lib/ucode/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/umdnsd/. $(1)/usr/share/umdnsd/
	$(INSTALL_DATA) ./files/usr/share/ucode/cli/modules/mdns.uc \
		$(1)/usr/share/ucode/cli/modules/
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/umdns.json \
		$(1)/usr/share/rpcd/acl.d/
	$(INSTALL_BIN) ./files/etc/init.d/umdns $(1)/etc/init.d/umdns
	$(INSTALL_CONF) ./files/etc/config/umdns $(1)/etc/config/umdns
	$(call InstallSeccomp,$(1),./files/ucode-mdns.json)
endef

$(eval $(call BuildPackage,ucode-mdns))
