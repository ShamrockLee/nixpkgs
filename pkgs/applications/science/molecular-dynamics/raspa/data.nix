{ lib
, stdenvNoCC
, gzip
, raspa
}:

stdenvNoCC.mkDerivation rec {
  pname = "raspa-data";
  inherit (raspa) version src;
  # TODO: Remove "out" from the outputs and
  # remove the line `mkdir "$out"` from installPhase
  # when #16182 get solved.
  outputs = [ "examples" "doc" "out" ];
  nativeBuildInpuhs = [ gzip ];
  installPhase = ''
    runHook preInstall
    mkdir -p "$examples/share/raspa"
    mv examples "$examples/share/raspa"
    mkdir -p "$doc/share/raspa"
    mv -T "Docs" "$doc/share/raspa/doc"
    mkdir "$out"
    runHook postInstall
  '';
  dontFixup = true;
  meta = removeAttrs raspa.meta [
    "available"
    "broken"
    "insecure"
    "mainProgram"
    "name"
  ] // {
    description = "Example packs and documentation of RASPA";
    outputsToInstall = [ "examples" "doc" ];
    platforms = lib.platforms.all;
  };
}
