{ appimageTools, lib, fetchurl, pkgs, gtk3, gsettings-desktop-schemas, version }:

let
  pname = "lossless-cut";
  nameCamel = "LosslessCut";
  name = "${pname}-${version}";
  nameSource = "${nameCamel}-linux.AppImage";
  nameExecutable = "losslesscut";
  owner = "mifi";
  src = fetchurl {
    url = "https://github.com/${owner}/${pname}/releases/download/v${version}/${nameSource}";
    name = nameSource;
    sha256 = "0gf9mnlfg2l00w41q9ria6s5f2s6d96hnzv143sw9l2gaqk4xwrh";
  };
  extracted = appimageTools.extractType2 {
    inherit name src;
  };
in appimageTools.wrapType2 {

  inherit name src;

  profile = ''
    export LC_ALL=C.UTF-8
    export XDG_DATA_DIRS=${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}:$XDG_DATA_DIRS
  '';

  extraPkgs = ps: appimageTools.defaultFhsEnvArgs.multiPkgs ps;

  extraInstallCommands = ''
    mv $out/bin/{${name},${nameExecutable}}
    (
      mkdir -p $out/share
      cd ${extracted}/usr
      find share -mindepth 1 -type d -exec mkdir -p $out/{} \;
      find share -mindepth 1 -type f,l -exec ln -s $PWD/{} $out/{} \;
    )
    ln -s ${extracted}/${nameExecutable}.png $out/share/icons/${nameExecutable}.png
    mkdir $out/share/applications
    cp ${extracted}/${nameExecutable}.desktop $out/share/applications
    substituteInPlace $out/share/applications/${nameExecutable}.desktop \
        --replace AppRun ${nameExecutable}
  '';

  meta.platforms = with lib.platforms;
    (lib.lists.intersectLists x86_64 (
      linux ++ freebsd ++ netbsd ++ openbsd
    ));
}
