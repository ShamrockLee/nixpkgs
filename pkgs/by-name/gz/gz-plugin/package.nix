{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  cmake,
  gz-cmake
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  pname = "gz-plugin";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "gazebosim";
    repo = "gz-plugin";
    rev = "gz-plugin${lib.head (lib.splitString "." finalAttrs.version)}_${finalAttrs.version}";
    hash = "sha256-h2Dx0KcFmJlS67q0v1zbd9nQkTCKgHkxt5KKTT5v+fw=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gz-cmake
  ];

  strictDeps = true;

  cmakeFlags =
    # TODO(@ShamrockLee):
    # Remove after a unified way to specify CMake definitions becomes available.
    lib.mapAttrsToList (
      n: v:
      let
        specifiedType = finalAttrs.cmakeDefinitionTypes.${n} or "";
        type =
          if specifiedType != "" then
            specifiedType
          else if lib.isBool v then
            "bool"
          else
            "string";
      in
      if lib.toUpper type == "BOOL" then lib.cmakeBool n v else lib.cmakeOptionType type n v
    ) finalAttrs.cmakeDefinitions;

  doCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Cross-platform C++ library for dynamically loading plugins";
    homepage = "https://github.com/gazebosim/gz-plugin";
    changelog = "https://github.com/gazebosim/gz-plugin/blob/${finalAttrs.src.rev}/Changelog.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    mainProgram = "gz-plugin";
    platforms = lib.platforms.all;
  };
})
