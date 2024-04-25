{ stdenvNoCC
, lib
, makeWrapper
, shellcheck-minimal
, argc
, bash
, coreutils
, curl
, jq
, unzip
, nix
, nix-prefetch-vsix-lib
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  __structuredAttrs = true;

  pname = "nix-prefetch-vscode-marketplace";
  version = "0.1.0";

  preferLocalBuild = true;

  src = ./nix-prefetch-vscode-marketplace;

  dontUnpack = true;

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    bash
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp "$src" "$out/bin/nix-prefetch-vscode-marketplace"
    chmod +x "$out/bin/nix-prefetch-vscode-marketplace"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/nix-prefetch-vscode-marketplace" \
      --prefix PATH : "${lib.makeBinPath [
        argc
        coreutils
        curl
        jq
        unzip
        nix
        nix-prefetch-vsix-lib
      ]}"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    shellcheck-minimal
    nix-prefetch-vsix-lib
  ];

  installCheckPhase = ''
    runHook preInstallCheck
    while IFS= read -r -d "" file; do
      shellcheck -x -P "$PATH" "$file"
    done < <(find "$out/bin" -mindepth 1 -type f,l -print0)
    runHook postInstallCheck
  '';

  meta = with lib; {
    description = "Prefetch vscode extensions from the official marketplace";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ ShamrockLee ];
  };
})
