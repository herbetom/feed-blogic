include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-mod-tty
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blogic/ucode-mod-tty.git
PKG_SOURCE_DATE:=2026-08-19
PKG_SOURCE_VERSION:=553a9cd21feb66147174e12d6611794e717129b1

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ucode-mod-tty
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Serial port module for ucode
  DEPENDS:=+libucode +libubox
endef

define Package/ucode-mod-tty/description
  Serial port module for ucode driven by uloop. Provides raw and line
  based modes, hardware flow control, DTR and RTS control, and event
  callbacks for open, receive, error and close.
endef

define Package/ucode-mod-tty/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ucode/tty.so $(1)/usr/lib/ucode/
endef

$(eval $(call BuildPackage,ucode-mod-tty))
