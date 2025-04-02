{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  cmake,
  gz-cmake,
  gz-common,
  gz-math,
  gz-plugin,
  libsdformat
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  pname = "gz-physics";
  version = "8.0.0";

  src = fetchFromGitHub {
    owner = "gazebosim";
    repo = "gz-physics";
    rev = "gz-physics${lib.head (lib.splitString "." finalAttrs.version)}_${finalAttrs.version}";
    hash = "sha256-PjwrJG3xvRYrkHDTaBUgoaW8NglEYDPuJrk4QjJjTHU=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gz-cmake
    gz-common
    gz-math
    gz-plugin
    libsdformat
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
    description = "Abstract physics interface designed to support simulation and rapid development of robot applications";
    homepage = "https://github.com/gazebosim/gz-physics";
    changelog = "https://github.com/gazebosim/gz-physics/blob/${finalAttrs.src.rev}/Changelog.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    mainProgram = "gz-physics";
    platforms = lib.platforms.all;
  };
})
