include $(TOPDIR)/rules.mk

PKG_NAME:=ucode-mod-curl
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/blogic/ucode-mod-curl.git
PKG_MIRROR_HASH:=d8555041afdf50a86a2617026c0bdd0d4a8ea8c9fd91ba052e52b19a4052e351
PKG_SOURCE_DATE:=2026-08-20
PKG_SOURCE_VERSION:=3891f509ea5c6974fa7c887c26784311edd9df16

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE.txt
PKG_MAINTAINER:=John Crispin <john@phrozen.org>

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ucode-mod-curl
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=HTTP client module for ucode
  DEPENDS:=+libucode +libubox +libcurl
endef

define Package/ucode-mod-curl/description
HTTP client module for ucode. It binds libcurl to ucode and drives the
transfers from uloop, so a request does not block the event loop. It runs
many requests at the same time. It supports all HTTP methods, custom
headers, mutual TLS with a client certificate, streaming uploads and
downloads, and progress callbacks.
endef

define Package/ucode-mod-curl/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/ucode/curl.so $(1)/usr/lib/ucode/
endef

$(eval $(call BuildPackage,ucode-mod-curl))
