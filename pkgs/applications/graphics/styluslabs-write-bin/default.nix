{ lib, stdenvNoCC, callPackage }:
let
  pname = "styluslabs-write";
  version = "3.0.0";
  metaCommon = with lib; {
    description = "A word processor for handwriting";
    longDescription = ''
      Write is a hand-writing word processor
      that stores the output files in HTML / SVG or SVGZ (gzipped svg)
      and offers extra features such as
      hyperlinking to websites and bookmarks (other works).
    '';
    homepage = "http://www.styluslabs.com";
    downloadPage = "http://www.styluslabs.com/download";
    license = licenses.unfree;
    maintainers = with maintainers; [ ShamrockLee ];
  };
  buildLinuxbin = callPackage ./build-linuxbin.nix { };
  buildDmg = callPackage ./build-dmg.nix { };
  linuxbin-x86_64 = buildLinuxbin {
    inherit pname version metaCommon;
    urlSuffix = null;
    platforms = [ "x86_64-linux" ];
    waybackRev = "20211023081747";
    sha256 = "EQiYOd+yCmacFrsZojQr8YqLghqyErdYg8TzhxNqETQ=";
  };
  linuxbin-aarch64 = buildLinuxbin {
    inherit pname version metaCommon;
    urlSuffix = "arm64";
    platforms = [ "aarch64-linux" ];
    waybackRev = "20211023113132";
    sha256 = "pJdiOPwF9+LoOTc2956+Ap9EXz6a9Ltzh1AAr5cvBUo=";
  };
  dmg = buildDmg {
    inherit pname version metaCommon;
    platforms = lib.platforms.darwin;
    waybackRev = "20211023154512";
    sha256 = "1n8vjxqdcfnvjmbl1h28xk1gz7zawm3yljc9ryc0l5wlsnmjff0c";
  };
in
(
  if stdenvNoCC.isDarwin then dmg
  else if stdenvNoCC.isLinux then
    (
      if stdenvNoCC.isAarch64 then linuxbin-aarch64
      else linuxbin-x86_64
    ) else abort "Unsupported platform"
).overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // {
    inherit
      linuxbin-x86_64
      linuxbin-aarch64
      dmg
      ;
  };
  meta = (oldAttrs.meta or { }) // {
    platforms = lib.flatten (map (m: m.meta.platforms or [ ]) [
      linuxbin-x86_64
      linuxbin-aarch64
      dmg
    ]);
  };
})
