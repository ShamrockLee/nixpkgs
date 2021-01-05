{ pkgs, stdenvNoCC, lib }:
let
  version = "3.30.0";
  callBin = pathExpression:
    (pkgs.callPackage pathExpression { inherit version; }).overrideAttrs
    (oldAttrs: { meta = meta // (oldAttrs.meta or { }); });
  passthru = {
    appimage = callBin ./appimage.nix;
    dmg = callBin ./dmg.nix;
    windows = callBin ./windows.nix;
  };
  meta = with lib; {
    description = "The swiss army knife of lossless video/audio editing";
    homepage = "https://mifi.no/losslesscut/";
    license = licenses.mit;
    maintainers = with maintainers; [ ShamrockLee ];
  };
in (
  if stdenvNoCC.isDarwin then passthru.dmg
  else if stdenvNoCC.isCygwin then passthru.windows
  else passthru.appimage
).overrideAttrs
(oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // passthru;
  meta = oldAttrs.meta // {
    platforms = passthru.appimage.meta.platforms
      ++ passthru.appimage.meta.platforms
      ++ passthru.dmg.meta.platforms
      ++ passthru.windows.meta.platforms;
  };
})
