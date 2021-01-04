{ stdenv, lib, fetchurl, undmg, version }:

let
  pname = "caprine";
  nameCamel = "Caprine";
  nameSource = "${nameCamel}-${version}.dmg";
  nameApp = nameCamel + ".app";
  src = fetchurl {
    url =
      "https://github.com/sindresorhus/caprine/releases/download/v${version}/${nameSource}";
    name = nameSource;
    sha256 = "1043g1qcykdxd4dp7pcz6bp3wg1ldmimvnlv39glmxwbblb6i9yi";
  };
in stdenv.mkDerivation {

  inherit pname version src;

  nativeBuildInputs = [ undmg ];

  unpackPhase = ''
    undmg ${src}
  '';
  sourceRoot = nameApp;

  installPhase = ''
    mkdir -p $out/Applications/${nameApp}
    cp -R . $out/Applications/${nameApp}
  '';

  meta.platforms = with lib.platforms; darwin;
}
