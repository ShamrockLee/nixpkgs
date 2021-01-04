{ pkgs, stdenv, lib }:
let
  version = "2.51.2";
  callBin = pathExpression:
    (pkgs.callPackage pathExpression { inherit version; }).overrideAttrs
    (oldAttrs: { meta = meta // (oldAttrs.meta or { }); });
  passthru = {
    appimage = callBin ./appimage.nix;
    dmg = callBin ./dmg.nix;
  };
  meta = with lib; {
    description = "An elegant Facebook Messenger desktop app";
    homepage = "https://sindresorhus.com/caprine/";
    license = licenses.mit;
    maintainers = with maintainers; [ ShamrockLee ];
  };
in (
  if stdenv.isDarwin then passthru.dmg
  else passthru.appimage).overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // passthru;
  meta = oldAttrs.meta // {
    platforms = passthru.appimage.meta.platforms
      ++ passthru.dmg.meta.platforms;
  };
})
