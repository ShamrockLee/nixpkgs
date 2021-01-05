{ stdenvNoCC
, lib
, fetchurl
, unzip
, version
, useMklink ? false
, customSymlinkCommand ? null
}:
let
  pname = "lossless-cut";
  nameCamel = "LosslessCut";
  nameSourceBase = "${nameCamel}-win";
  nameSource = "${nameSourceBase}.zip";
  nameExecutable = "${nameCamel}.exe";
  owner = "mifi";
  getSymlinkCommand = if (customSymlinkCommand != null) then customSymlinkCommand
    else if useMklink then (targetPath: linkPath: "mklink ${targetPath} ${linkPath}")
    else (targetPath: linkPath: "ln -s ${targetPath} ${linkPath}");
in stdenvNoCC.mkDerivation {

  inherit pname version;

  src = fetchurl {
    name = nameSource;
    url = "https://github.com/${owner}/${pname}/releases/download/v${version}/${nameSource}";
    sha256 = "05ls5im9ln8db5fxd09wi4mvhand2b1gqvz20hdh8zn3rg1gjpsp";
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    unzip $src -d ${nameSourceBase}
  '';

  sourceRoot = nameSourceBase;

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/libexec
    cd ..
    mv ${nameSourceBase} $out/libexec

  '' + (getSymlinkCommand "${nameSourceBase}/${nameExecutable}" "$out/bin/${nameExecutable}");

  meta.platforms = with lib.platforms; windows;
}
