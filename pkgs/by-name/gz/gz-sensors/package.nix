{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  cmake,
  gz-cmake,
  gz-common,
  gz-math,
  gz-transport,
  gz-msgs,
  gz-rendering
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  pname = "gz-sensors";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "gazebosim";
    repo = "gz-sensors";
    rev = "gz-gui${lib.head (lib.splitString "." finalAttrs.version)}_${finalAttrs.version}";
    hash = "sha256-8Ato7/YRL7JebbVPASD6VF9lf/Uyq26MIg2l+jQ4GDk=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gz-cmake
    gz-common
    gz-math
    gz-transport
    gz-msgs
    gz-rendering
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
    description = "Provides numerous sensor models designed to generate realistic data from simulation environments";
    homepage = "https://github.com/gazebosim/gz-sensors";
    changelog = "https://github.com/gazebosim/gz-sensors/blob/${finalAttrs.src.rev}/Changelog.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    mainProgram = "gz-sensors";
    platforms = lib.platforms.all;
  };
})
