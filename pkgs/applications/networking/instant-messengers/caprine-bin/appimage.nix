{ lib, appimageTools, fetchurl, pkgs, gtk3, gsettings-desktop-schemas, version }:

let
  pname = "caprine";
  nameCamel = "Caprine";
  name = "${pname}-${version}";
  nameSource = "${nameCamel}-${version}.AppImage";
  nameExecutable = pname;
  src = fetchurl {
    url = "https://github.com/sindresorhus/caprine/releases/download/v${version}/${nameSource}";
    name = nameSource;
    sha256 = "0d2lky0shg471cz269ndn9gklibrcrw534m10fwjyplqkxjx0han";
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

  extraPkgs = pkgs: appimageTools.defaultFhsEnvArgs.multiPkgs pkgs;

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
