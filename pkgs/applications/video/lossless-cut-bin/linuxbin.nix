# Binary currently ususable (but is build successfully).

{ version
, stdenv
, lib
, fetchurl
, wrapGAppsHook
, autoPatchelfHook
, alsaLib
, cups
, gnome3
, nss
, nspr
, xorg
, forceNativeFF ? true
, libraryFF ? ffmpeg_4.out
, ffmpeg_4 ? null
}:

assert forceNativeFF -> libraryFF != null;

let
  pname = "lossless-cut";
  nameCamel = "LosslessCut";
  nameSourceBase = "${nameCamel}-linux";
  nameSource = "${nameSourceBase}.tar.bz2";
  nameExecutable = "losslesscut";
in stdenv.mkDerivation {

  inherit pname version;

  src = fetchurl {
    url = "https://github.com/mifi/${pname}/releases/download/v${version}/${nameSource}";
    name = nameSource;
    sha256 = "0kkhxscb6jp6yy95k6qyvq7jnxin83i7iq5rm1va4y7zw380qqwy";
  };

  nativeBuildInputs = [ autoPatchelfHook wrapGAppsHook ];
  buildInputs = [
      # gcc-unwrapped.lib # libstdc++.so.6
      alsaLib # libasound.so.2
      cups.lib # libcups.so.2
      gnome3.gtk
      nss # libnss3.so, libnssutil3.so
      nspr # libnspr4.so
      xorg.libXdamage # libXdamage.so.1
      xorg.libXtst # libXtst.so.6
      xorg.libXScrnSaver # libXss.so.1
      xorg.xcbutil # libxcb.so.1
      xorg.xcursorgen # libXcursor.os.1
      xorg.libXext # libXext.so.6
      xorg.libXrender # libXrender.so.1
      xorg.libXi # libXi.so.6
      xorg.libXfixes # libXfixes.so.3
      xorg.libXcomposite # libXcomposite.so.1
    ] ++ (lib.lists.optional forceNativeFF [ libraryFF ]);

  sourceRoot = nameSourceBase;

  installPhase = lib.strings.optionalString forceNativeFF ''
    rm -r resources/node_modules/ffmpeg-ffprobe-static
    # rm libffmpeg.so*
  '' + ''
    cd ..
    mkdir -p "$out/libexec"
    mv ${nameSourceBase} "$out/libexec/"
    mkdir -p "$out/bin"
    ln -s "$out/libexec/${nameSourceBase}/${nameExecutable}" "$out/bin/${nameExecutable}"
  '';

  dontWrapGApps = true;

  preFixup = ''
    wrapGApp $out/bin/${nameExecutable}
  '';

  meta.platforms = with lib.platforms;
    (lib.lists.intersectLists x86_64 (
      linux ++ freebsd ++ netbsd ++ openbsd
    ));

  meta.broken = true;
}
