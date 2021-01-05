{ stdenv, fetchurl, undmg, version }:

let
  pname = "lossless-cut";
  nameCamel = "LosslessCut";
  nameSource = "${nameCamel}-mac.dmg";
  nameApp = nameCamel + ".app";
  src = fetchurl {
    url = "https://github.com/sindresorhus/${pname}/releases/download/v${version}/${nameSource}";
    name = nameSource;
    sha256 = "1z7h6mwb6dwdj9hy5kfpxc065nn81fbq860afrl1r8xq26rpz2wp";
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

  meta.platforms = with stdenv.lib.platforms; darwin;
}
