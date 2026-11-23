#!/bin/bash
# ============================================================
# MaxOS 1.0 build script for crave.io
# Run inside crave:   crave run "bash build-maxos.sh"
#
# Crave rules respected:
#  - NO clean builds: source tree syncs ONCE, then persists.
#    Every later run is incremental (out/ is kept).
#  - Single account, single project, no abuse.
# ============================================================
set -e
TREE="$HOME/maxos-tree"
REPO_URL="https://github.com/crdroidandroid/android.git"
BRANCH="16.0"
GH_RAW="https://raw.githubusercontent.com/MaxGamingood/maxos-gsi/main"

# ---------- Phase 1: one-time source setup ----------
if [ ! -d "$TREE/.repo/manifests" ]; then
  echo "[MaxOS] FIRST RUN: repo init + sync (happens once, then persists)"
  mkdir -p "$TREE" && cd "$TREE"
  repo init -u "$REPO_URL" -b $BRANCH --depth=1 --git-lfs
  git clone https://github.com/TrebleDroid/treble_manifest .repo/local_manifests -b android-16.0 --depth=1
  # crDroid compatibility fixes (proven in our CI iterations)
  sed -i 's/<remote name="github" fetch="https:\/\/github.com\/" \/>/<remote name="maxosgh" fetch="https:\/\/github.com\/" \/>/; s/remote="github"/remote="maxosgh"/g' .repo/local_manifests/manifest.xml
  sed -i 's/<remove-project /<remove-project optional="true" /' .repo/local_manifests/remove.xml
  rm -f .repo/local_manifests/replace.xml
  repo sync -c -j"$(nproc)" --no-clone-bundle --no-tags --force-sync
else
  echo "[MaxOS] tree exists - incremental mode, no clean sync (crave rule)"
fi
cd "$TREE"

# ---------- Phase 2: refresh MaxOS layer from GitHub ----------
mkdir -p device/maxos/keylayout
curl -sL "$GH_RAW/maxos/maxos.mk"                            -o device/maxos/maxos.mk
curl -sL "$GH_RAW/maxos/maxos.prop"                          -o device/maxos/maxos.prop
curl -sL "$GH_RAW/maxos/keylayout/Vendor_0001_Product_0001.kl" -o device/maxos/keylayout/Vendor_0001_Product_0001.kl
curl -sL "$GH_RAW/maxos/bootanimation.zip"                   -o device/maxos/bootanimation.zip

# ---------- Phase 3: generate treble targets + build ----------
rm -f device/*/sepolicy/common/private/genfs_contexts || true
bash device/phh/treble/generate.sh device/phh/treble/lineage.mk device/maxos/maxos.mk
ls device/phh/treble/treble_arm64_bvN.mk >/dev/null && echo "[MaxOS] target generated"
source build/envsetup.sh
lunch treble_arm64_bvN-userdebug
make WITHOUT_CHECK_API=true -j"$(nproc)" systemimage

# ---------- Phase 4: package ----------
IMG=$(find out/target/product -name system.img | head -1)
xz -c "$IMG" -T0 > "$HOME/maxos-1.0-arm64-ab.img.xz"
echo "[MaxOS] BUILD COMPLETE: $HOME/maxos-1.0-arm64-ab.img.xz"
echo "[MaxOS] retrieve it with:  crave pull $HOME/maxos-1.0-arm64-ab.img.xz"
df -h "$HOME" | tail -1
