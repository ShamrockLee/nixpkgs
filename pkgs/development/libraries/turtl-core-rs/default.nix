{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libsodium
, openssl
, sqlite
}:

rustPlatform.buildRustPackage rec {
  pname = "turtl-core-rs";
  version = "unstable-2020-03-27";

  passthru = {
    inherit libsodium;
  };

  src = fetchFromGitHub {
    owner = "turtl";
    repo = "core-rs";
    rev = "e4132bd03afa7c85bbc8fa098a7e7174249ec643";
    sha256 = "1spjh6mns48ph2ms3x3qgm4bj6masmnr060pkv9831fgfpc8g6ys";
  };

  cargoSha256 = "sha256-Wh4nrOkte9v9TgE0IyjaD9TPM7F7AWtrRNKNv08roeM=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libsodium
    openssl
    sqlite
  ];

  meta = with lib; {
    homepage = "https://github.com/turtl/core-rs";
    description = "The Rust core for Turtl";
    longDescription = ''
      This is the Rust core for Turtl.
      It houses the logic for Turtl's main client operations
      and is meant to be embedded as a shared/static library
      that is standard across all platforms.
    '';
    license = licenses.gpl3;
    platforms = platforms.all;
    maintainers = with maintainers; [ ShamrockLee ];
  };

}
