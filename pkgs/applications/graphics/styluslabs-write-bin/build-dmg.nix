{ lib
, stdenvNoCC
, fetchurl
, undmg
}:

{ pname
, version
, metaCommon
, urlSuffix ? null
, platforms
, waybackRev ? null
, sha256 ? lib.fakeSha256
}:

stdenvNoCC.mkDerivation rec {
  inherit pname version waybackRev;

  src = fetchurl {
    # Example:
    # https://web.archive.org/web/20211023154512/http://www.styluslabs.com/write/write300.dmg
    url = (lib.optionalString (waybackRev != null) "https://web.archive.org/web/${waybackRev}/")
      + "http://www.styluslabs.com/write/write${
      (lib.concatStrings (lib.splitString "." version)
      ) + lib.optionalString (urlSuffix != null) ("_" + urlSuffix)
    }.dmg";
    inherit sha256;
  };

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications/Write.app"
    cp -R . "$out/Applications/Write.app"

    runHook postInstall
  '';

  meta = with lib; metaCommon // {
    inherit platforms;
    mainProgram = "Write";
  };
}
