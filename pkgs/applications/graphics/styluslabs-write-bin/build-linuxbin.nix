{ lib
, stdenvNoCC
, fetchzip
, autoPatchelfHook
, desktop-file-utils
, SDL2
, gcc-unwrapped
}:

{ pname
, version
, metaCommon ? { }
, urlSuffix ? null
, platforms
, waybackRev ? null
, sha256 ? lib.fakeSha256
}:

stdenvNoCC.mkDerivation {
  inherit pname version waybackRev;

  # Fetch from the Wayback'ed page in case the vendor changes the content
  # Example:
  # https://web.archive.org/web/20211023113132/http://www.styluslabs.com/write/write300_arm64.tar.gz
  src = fetchzip {
    url = (lib.optionalString (waybackRev != null) "https://web.archive.org/web/${waybackRev}/")
      + "http://www.styluslabs.com/write/write${
      (lib.concatStrings (lib.splitString "." version)
      ) + lib.optionalString (urlSuffix != null) ("_" + urlSuffix)
    }.tar.gz";
    inherit sha256;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    desktop-file-utils
  ];

  buildInputs = [
    SDL2
    gcc-unwrapped.lib
  ];

  # The bundled fonts `*.ttf` need to stay next to the executable `Write`
  # but are not suitable to appear inside `$out/bin`. This is workarounded
  # by placing the executable inside `opt` along the fonts and then link to `bin`
  # Place `opt` in a seperate output to prevent it from showing up in the profile
  # to eliminate possible conflicts.
  outputs = [ "out" "opt" ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$opt/opt/Write"
    mv "./Write" "$opt/opt/Write/"
    mv *.ttf "$opt/opt/Write/"

    mkdir -p "$out/bin"
    ln -s "$opt/opt/Write/Write" "$out/bin/Write"

    mkdir -p "$out/share/icons/hicolor/144x144/apps"
    mv "./Write144x144.png" "$out/share/icons/hicolor/144x144/apps/Write.png"

    mkdir -p "$out/share/applications"
    desktop-file-edit --set-key=Exec --set-value="$out/bin/Write" "./Write.desktop"
    desktop-file-edit --set-key=Icon --set-value="$out/share/icons/hicolor/144x144/apps/Write.png" "./Write.desktop"
    mv "./Write.desktop" "$out/share/applications/"

    mkdir -p "$out/share/doc/Write"
    mv "./Intro.svg" "./INSTALL" "$out/share/doc/Write/"

    runHook postInstall
  '';

  meta = with lib; metaCommon // {
    inherit platforms;
    mainProgram = "Write";
  };
}
