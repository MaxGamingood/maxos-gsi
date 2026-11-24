# MaxOS device layer - LG V60 ThinQ 5G (timelm)
# Injected via generate.sh alongside device/phh/treble/lineage.mk

# V60 fixes as compile-time defaults (bugmap: D:\v60-gsi-project\BUGMAP.md)
PRODUCT_SYSTEM_EXT_PROPERTIES += \
    persist.sys.overlay.devinputjack=true \
    persist.sys.phh.caf.audio_policy=1 \
    persist.sys.phh.include_all_cameras=true \
    camera.aux.packagelist=nothing \
    vendor.camera.aux.packagelist=nothing \
    ro.maxos.version=1.0 \
    ro.modversion=MaxOS-1.0-arm64-ab

# Assistant button: KEY_TV (377) -> ASSIST on gpio-keys
PRODUCT_COPY_FILES += \
    device/maxos/keylayout/Vendor_0001_Product_0001.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_0001_Product_0001.kl

# MaxOS boot animation
PRODUCT_COPY_FILES += \
    device/maxos/bootanimation.zip:$(TARGET_COPY_OUT_SYSTEM)/media/bootanimation.zip

# Exclude test trees whose infrastructure we intentionally do not sync
# (same mechanism crDroid uses for -kernel/platform / -prebuilts/misc/protobuf_vendorcompat)
PRODUCT_SOURCE_ROOT_DIRS += \
    -tools/loganalysis \
    -test/suite_harness/common/util
# plus the auto-generated list (tests dirs discovered at build time)
-include device/maxos/exclusions.mk
