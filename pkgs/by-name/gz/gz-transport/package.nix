{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  cmake,
  gz-cmake,
  gz-msgs,
  gz-tools
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  pname = "gz-transport";
  version = "14.0.0";

  src = fetchFromGitHub {
    owner = "gazebosim";
    repo = "gz-transport";
    rev = "gz-transport${lib.head (lib.splitString "." finalAttrs.version)}_${finalAttrs.version}";
    hash = "sha256-zoGphy2cpmqJsnyS1LNVm4eGtHCWkAwIblga4RdVj4k=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gz-cmake
    gz-msgs
    gz-tools
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
    description = "Transport library for component communication based on publication/subscription and service calls";
    homepage = "https://github.com/gazebosim/gz-transport";
    changelog = "https://github.com/gazebosim/gz-transport/blob/${finalAttrs.src.rev}/Changelog.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    mainProgram = "gz-transport";
    platforms = lib.platforms.all;
  };
})
