{ stdenv, lib, bundlerEnv, bundlerUpdateScript, makeWrapper, groff }:

stdenv.mkDerivation rec {
  pname = "ronn";
  version = env.gems.ronn.version;

  env = bundlerEnv {
    name = "ronn-gems";
    gemdir = ./.;
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    makeWrapper ${env}/bin/ronn $out/bin/ronn \
      --set PATH ${groff}/bin
  '';

  passthru.updateScript = bundlerUpdateScript "ronn";

  meta = with lib; {
    description = "Markdown-based tool for building manpages";
    longDescription = ''
      This is the original ronn project.
      The last commit was made on August 2013, and the last version `0.7.3`.
    '';
    homepage = "https://rtomayko.github.io/ronn/";
    license = licenses.mit;
    maintainers = with maintainers; [ zimbatm nicknovitski ];
    platforms = env.ruby.meta.platforms;
    mainProgram = "ronn";
  };
}
