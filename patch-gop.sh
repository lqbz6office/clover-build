#!/bin/bash
# Apply CloverGopDxe into edk2-msm sdm660, so the sdm660 UEFI publishes GOP
# over the framebuffer ABL leaves at 0x9D400000 (1200x1920).
set -euo pipefail

EDK2="$1"   # path to the edk2-msm checkout
SRC="$2"    # dir holding CloverGopDxe.c and CloverGopDxe.inf

# 1. place the driver source under the sdm660 platform
DEST="$EDK2/Platform/Qualcomm/sdm660/Drivers/CloverGopDxe"
mkdir -p "$DEST"
cp "$SRC/CloverGopDxe.c"  "$DEST/"
cp "$SRC/CloverGopDxe.inf" "$DEST/"

# 2. declare it in sdm660.dsc [Components.common]
DSC="$EDK2/Platform/Qualcomm/sdm660/sdm660.dsc"
if ! grep -q "CloverGopDxe.inf" "$DSC"; then
  # append right after [Components.common]
  python3 - "$DSC" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
if 'CloverGopDxe' not in s:
    s = s.replace('[Components.common]\n',
                  '[Components.common]\n  Platform/Qualcomm/sdm660/Drivers/CloverGopDxe/CloverGopDxe.inf\n')
    open(p,'w').write(s)
    print('dsc: added CloverGopDxe component')
else:
    print('dsc: already present')
PY
fi

# 3. add the FILE block to dxe.fdf.inc (compiled INF -> DXE FV)
FDF="$EDK2/Platform/Qualcomm/sdm660/dxe.fdf.inc"
if ! grep -q "CloverGopDxe" "$FDF"; then
  python3 - "$FDF" <<'PY'
import sys
p = sys.argv[1]
s = open(p).read()
if 'CloverGopDxe' not in s:
    block = '''  INF Platform/Qualcomm/sdm660/Drivers/CloverGopDxe/CloverGopDxe.inf

'''
    # append at end (GOP should be late, after clocks/storage)
    s = s.rstrip('\n') + '\n' + block
    open(p,'w').write(s)
    print('fdf: added CloverGopDxe INF')
else:
    print('fdf: already present')
PY
fi

echo "patch done"
