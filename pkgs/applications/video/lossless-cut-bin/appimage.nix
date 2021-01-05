{ appimageTools, lib, fetchurl, pkgs, gtk3, gsettings-desktop-schemas, version }:

let
  pname = "lossless-cut";
  nameCamel = "LosslessCut";
  name = "${pname}-${version}";
  nameSource = "${nameCamel}-linux.AppImage";
  nameExecutable = "losslesscut";
in appimageTools.wrapType2 {

  inherit name;

  src = fetchurl {
    url = "https://github.com/mifi/${pname}/releases/download/v${version}/${nameSource}";
    name = nameSource;
    sha256 = "0gf9mnlfg2l00w41q9ria6s5f2s6d96hnzv143sw9l2gaqk4xwrh";
  };

  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  extraPkgs = ps: appimageTools.defaultFhsEnvArgs.multiPkgs ps;

  extraInstallCommands = "mv $out/bin/{${name},${nameExecutable}}";

  meta.platforms = with lib.platforms;
    (lib.lists.intersectLists x86_64 (
      linux ++ freebsd ++ netbsd ++ openbsd
    ));
}
