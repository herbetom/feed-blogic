include $(TOPDIR)/rules.mk

PKG_NAME:=uconfig

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git@github.com:blogic/uconfig.git
PKG_SOURCE_VERSION:=09362f4c27d92e19bcb5f69eb230dd37496bd5ec

PKG_MAINTAINER:=John Crispin <john@phrozen.org>
PKG_LICENSE:=ISC

PKG_BUILD_DEPENDS:=python3/host
PYTHON3_PKG_BUILD:=0
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=./host-pip-requirements.txt

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_SOURCE_DIR:=$(PKG_BUILD_DIR)/src
CMAKE_BINARY_DIR:=$(PKG_BUILD_DIR)/src

define uconfig/module
	$(INSTALL_DIR) $(1)/etc/uconfig/modules/
	touch $(1)/etc/uconfig/modules/$(2)
endef

define Package/uconfig
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer
  DEPENDS=+ucode-mod-nl80211 +ucode-mod-rtnl +ucode-mod-ubus \
  	  +ip-full +ip-bridge +ratelimit +pkgen +nlbwmon +wifi-dynamic +cli
endef

define Package/uconfig-mod-adguardhome
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (adguardhome plugin)
  DEPENDS=uconfig +adguardhome
endef

define Package/uconfig-mod-fingerprint
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (fingerprint plugin)
  DEPENDS=uconfig +ufp +ufp-neigh +udhcpsnoop +uconfig-mod-mdns
endef

define Package/uconfig-mod-ieee8021x
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (IEEE802.1x plugin)
  DEPENDS=uconfig +ucode-mod-log +ieee8021x
endef

define Package/uconfig-mod-lldp
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (LLDP plugin)
  DEPENDS=uconfig +lldpd
endef

define Package/uconfig-mod-mdns
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (MDNS plugin)
  DEPENDS=uconfig +umdns
endef

define Package/uconfig-mod-mesh-batman
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (Mesh/Batman plugin)
  DEPENDS=uconfig +kmod-batman-adv
endef

define Package/uconfig-mod-nlbwmon
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (nlbwmon plugin)
  DEPENDS=uconfig +nlbwmon
endef

define Package/uconfig-mod-qosify
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (qosify plugin)
  DEPENDS=uconfig +qosify
endef

define Package/uconfig-mod-samba4
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (samba4 plugin)
  DEPENDS=uconfig +samba4-server +blockd +kmod-usb-storage +kmod-fs-vfat +kmod-fs-exfat
endef

define Package/uconfig-mod-tailscale
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (tailscale plugin)
  DEPENDS=uconfig +tailscale
endef

define Package/uconfig-mod-ucoord
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (ucoord plugin)
  DEPENDS=uconfig +unetd +unet-cli +unetmsg
endef

define Package/uconfig-mod-state
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (state/discovery daemon)
  DEPENDS=uconfig +ucode-mod-rtnl +ucode-mod-nl80211 +ucode-mod-fs +nlbwmon +unetmsg
endef

define Package/uconfig-mod-ui
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=uConfig
  TITLE:=UCI renderer (webui plugin)
  DEPENDS=uconfig +uwsd +uconfig-mod-state
endef

define Build/Configure
        $(call Py3Build/InstallBuildDepends)
	$(call Build/Configure/Default)
endef

define Build/Compile
	$(PKG_BUILD_DIR)/generate.sh $(PKG_BUILD_DIR)/
endef

define Package/uconfig/conffiles
/etc/uconfig/configs/
/etc/uconfig/certificates/
/etc/uconfig/data/
endef

define Package/uconfig-mod-state/conffiles
/etc/uconfig/devices/
endef

define Package/uconfig-mod-ui/conffiles
/etc/uconfig/webui/
endef

define Package/uconfig/install
	$(INSTALL_DIR) $(1)/usr/share/ucode/ureader $(1)/etc/uconfig/configs $(1)/etc/uconfig/data
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/generated/schema.uc $(1)/usr/share/ucode/ureader/
	$(CP) $(PKG_BUILD_DIR)/files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/ucode/uconfig
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/src/utils.so $(1)/usr/lib/ucode/uconfig
	date +%s > $(1)/etc/uconfig/build_time
endef

define Package/uconfig-mod-adguardhome/install
	$(CP) $(PKG_BUILD_DIR)/modules/adguardhome/* $(1)/
	$(INSTALL_DIR) $(1)/usr/share/ucode/ureader/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/generated/modules/schemaServiceAdguardhome.uc $(1)/usr/share/ucode/ureader/
	$(call uconfig/module,$1,adguardhome)
endef

define Package/uconfig-mod-fingerprint/install
	$(CP) $(PKG_BUILD_DIR)/modules/fingerprint/* $(1)/
endef

define Package/uconfig-mod-ieee8021x/install
	$(INSTALL_DIR) $(1)/usr/share/ucode/uconfig/templates/services/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/ieee8021x/* $(1)/usr/share/ucode/uconfig/templates/services/
	$(INSTALL_DIR) $(1)/usr/share/ucode/ureader/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/generated/modules/schemaServiceIeee8021x.uc $(1)/usr/share/ucode/ureader/
endef

define Package/uconfig-mod-lldp/install
	$(CP) $(PKG_BUILD_DIR)/modules/lldp/* $(1)/
	$(INSTALL_DIR) $(1)/usr/share/ucode/ureader/
	$(CP) $(PKG_BUILD_DIR)/generated/modules/schemaServiceLldp.uc $(1)/usr/share/ucode/ureader/
	$(call uconfig/module,$1,lldp)
endef

define Package/uconfig-mod-mdns/install
	$(CP) $(PKG_BUILD_DIR)/modules/mdns/* $(1)/
	$(INSTALL_DIR) $(1)/usr/share/ucode/ureader/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/generated/modules/schemaServiceMdns.uc $(1)/usr/share/ucode/ureader/
	$(call uconfig/module,$1,mdns)
endef

define Package/uconfig-mod-mesh-batman/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(call uconfig/module,$1,batman-adv)
endef

define Package/uconfig-mod-nlbwmon/install
	$(INSTALL_DIR) $(1)/usr/share/ucode/uconfig/templates/services/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/nlbwmon/* $(1)/usr/share/ucode/uconfig/templates/services/
endef

define Package/uconfig-mod-qosify/install
	$(CP) $(PKG_BUILD_DIR)/modules/qosify/* $(1)/
	$(INSTALL_DIR) $(1)/usr/share/ucode/ureader/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/generated/modules/schemaServiceQualityOfService.uc $(1)/usr/share/ucode/ureader/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/generated/modules/schemaInterfaceQualityOfService.uc $(1)/usr/share/ucode/ureader/
	$(call uconfig/module,$1,qosify)
endef

define Package/uconfig-mod-samba4/install
	$(INSTALL_DIR) $(1)/usr/share/ucode/uconfig/templates/services/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/samba4/samba4.uc $(1)/usr/share/ucode/uconfig/templates/services/
	$(call uconfig/module,$1,samba4)
endef

define Package/uconfig-mod-state/install
	$(CP) $(PKG_BUILD_DIR)/modules/state/* $(1)/
endef

define Package/uconfig-mod-tailscale/install
	$(CP) $(PKG_BUILD_DIR)/modules/tailscale/* $(1)/
	$(INSTALL_DIR) $(1)/usr/share/ucode/ureader/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/generated/modules/schemaServiceTailscale.uc $(1)/usr/share/ucode/ureader/
	$(call uconfig/module,$1,tailscale)
endef

define Package/uconfig-mod-ucoord/install
	$(CP) $(PKG_BUILD_DIR)/modules/ucoord/* $(1)/
	$(INSTALL_DIR) $(1)/etc/uconfig/data
	$(call uconfig/module,$1,ucoord)
endef

define Package/uconfig-mod-ui/install
	$(CP) $(PKG_BUILD_DIR)/modules/webui/* $(1)/
endef

$(eval $(call BuildPackage,uconfig))
$(eval $(call BuildPackage,uconfig-mod-adguardhome))
$(eval $(call BuildPackage,uconfig-mod-fingerprint))
$(eval $(call BuildPackage,uconfig-mod-ieee8021x))
$(eval $(call BuildPackage,uconfig-mod-lldp))
$(eval $(call BuildPackage,uconfig-mod-mdns))
$(eval $(call BuildPackage,uconfig-mod-mesh-batman))
$(eval $(call BuildPackage,uconfig-mod-nlbwmon))
$(eval $(call BuildPackage,uconfig-mod-qosify))
$(eval $(call BuildPackage,uconfig-mod-samba4))
$(eval $(call BuildPackage,uconfig-mod-state))
$(eval $(call BuildPackage,uconfig-mod-tailscale))
$(eval $(call BuildPackage,uconfig-mod-ucoord))
$(eval $(call BuildPackage,uconfig-mod-ui))
