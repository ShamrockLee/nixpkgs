{ stdenv, lib, bundlerEnv, bundlerUpdateScript, makeWrapper, groff }:

stdenv.mkDerivation rec {
  pname = "ronn-ng";
  version = env.gems.ronn-ng.version;

  env = bundlerEnv {
    name = "ronn-ng-gems";
    gemdir = ./.;
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${env}/bin/ronn $out/bin/ronn \
      --set PATH ${groff}/bin
  '';

  passthru.updateScript = bundlerUpdateScript "ronn-ng";

  meta = with lib; {
    description = "Markdown-based tool for building manpages, an updated fork of ronn";
    longDescription = ''
      Ronn-NG is a currently maintained and updated fork of the original rtomayko/ronn.
      The last commit of the original ronn was made on August 2013,
      and the last version `0.7.3`.
      The Ronn-NG made the first release on December 2018 with version `0.8.0`.
    '';
    homepage = "https://github.com/apjanke/ronn-ng";
    license = licenses.mit;
    maintainers = with maintainers; [ zimbatm nicknovitski ShamrockLee ];
    platforms = env.ruby.meta.platforms;
    mainProgram = "ronn";
  };
}
