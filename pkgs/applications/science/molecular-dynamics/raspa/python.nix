{ lib
, raspa
, python
, pythonImportsCheckHook
, setuptoolsBuildHook
, setuptoolsCheckHook
, namePrefix
}:
let
  inherit (raspa) stdenv;
in
raspa.overrideAttrs (oldAttrs: rec {
  pname = "RASPA2";
  name = namePrefix + "${pname}-${oldAttrs.version}";
  nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [
    python
    setuptoolsBuildHook
  ];
  strictDeps = true;
  preInstall = oldAttrs.preInstall or "" + ''
    ln -s libraspa2.so libraspa2.${python.passthru.implementation}-${builtins.replaceStrings [ "." ] [ "" ] python.pythonVersion}-${stdenv.hostPlatform.system}-${stdenv.hostPlatform.parsed.abi.name}.so
    mkdir -p "python/simulations/lib"
  '';
  doInstallCheck = true;
  installCheckInputs = oldAttrs.installCheckInputs or [ ] ++ [
    setuptoolsCheckHook
  ] ++ lib.optionals (stdenv.buildPlatform == stdenv.hostPlatform) [
    pythonImportsCheckHook
  ];
  pythonImportsCheck = [
    "RASPA2"
  ];
  meta = removeAttrs oldAttrs.meta [ "name" ] // {
    description = "Python binding of RASPA, a general purpose classical molecular simulation package";
  };
})
