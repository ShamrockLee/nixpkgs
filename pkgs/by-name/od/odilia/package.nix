{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  libevdev,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  __structuredAttrs = true;

  pname = "odilia";

  # Reference the tip of the main branch,
  # since Odilia is currently beta and changing on a daily basis
  # and the tagged versions are years behind.
  version = "0.1.4-unstable-2025-06-07";

  src = fetchFromGitHub {
    owner = "odilia-app";
    repo = "odilia";
    rev = "435b0c6756736c22eda79455f2f6e7d81cada562";
    hash = "sha256-fwNqNYBkf6AjNrVb5LrQmd1eejXpqf6mcUfjqWC9Kpw=";
  };

  cargoHash = "sha256-FCdRw1JPRzEDVE67mq6wz+HCVwMoZLxqvqXwArvr6GM=";

  input-server-keyboard = rustPlatform.buildRustPackage {
    pname = "odilia-input-server-keyboard";
    inherit (finalAttrs)
      version
      src
      cargoDeps
      nativeBuildInputs
      buildInputs
      enableParallelBuilding
      ;
    buildAndTestSubdir = "input-server-keyboard";
    meta = finalAttrs.meta // {
      mainProgram = "odilia-input-server-keyboard";
    };
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs =
    [
      libevdev
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.AppKit
      darwin.apple_sdk.frameworks.IOKit
    ];

  enableParallelBuilding = true;

  postPatch = ''
    substituteInPlace odilia/src/main.rs \
      --replace-fail \
        'config::File::with_name("/etc/odilia/config")' \
        'config::File::with_name("/etc/odilia/config").required(false)' \
      --replace-fail \
        ${lib.escapeShellArg ''
          with_name(
          ${"\t\t\t"}config_path.to_str().expect("Valid UTF-8 path"),
          ${"\t\t"}));
        ''} \
        ${lib.escapeShellArg ''
          with_name(
          ${"\t\t\t"}config_path.to_str().expect("Valid UTF-8 path"),
          ${"\t\t"}).required(false));
        ''}
  '';

  postInstall = ''
    mkdir -p "$out/share/odilia"
    install -m644 odilia/config.toml "$out/share/odilia"
  '';

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      finalAttrs.input-server-keyboard
    ])
  ];

  postFixup = ''
    wrapProgram "$out/bin/odilia" "''${makeWrapperArgs[@]}"
  '';

  meta = {
    description = "Fast screen reader for the *nix desktop";
    homepage = "https://github.com/odilia-app/odilia";
    changelog = "https://github.com/odilia-app/odilia/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
    maintainers = with lib.maintainers; [
      ShamrockLee
    ];
    mainProgram = "odilia";
  };
})
