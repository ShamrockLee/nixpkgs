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
  gz-plugin,
  gz-tools
}:

stdenv.mkDerivation (finalAttrs: {
  __structuredAttrs = true;
  pname = "gz-gui";
  version = "9.0.0";

  src = fetchFromGitHub {
    owner = "gazebosim";
    repo = "gz-gui";
    rev = "gz-gui${lib.head (lib.splitString "." finalAttrs.version)}_${finalAttrs.version}";
    hash = "sha256-/YJW6XmdGwbyd5Nx3wcTqnRlpwE1unVGaNX91qfZmiM=";
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
    gz-plugin
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
    description = "Builds on top of Qt to provide widgets which are useful when developing robotics applications, such as a 3D view, plots, dashboard, etc, and can be used together in a convenient unified interface";
    homepage = "https://github.com/gazebosim/gz-gui";
    changelog = "https://github.com/gazebosim/gz-gui/blob/${finalAttrs.src.rev}/Changelog.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ShamrockLee ];
    mainProgram = "gz-gui";
    platforms = lib.platforms.all;
  };
})
