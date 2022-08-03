{ lib
, callPackage
, makeSetupHook
, gnused
}:
let
  tests = import ./test { inherit callPackage; };
in
{
  patchSourcetimePathBash = (makeSetupHook
    {
      name = "patch-sourcetime-path-bash";
      meta = with lib; {
        descriptions = "Setup-hook to inject source-time PATH prefix to a Bash/Ksh/Zsh script";
        maintainers = with maintainers; [ ShamrockLee ];
      };
    } ./patch-sourcetime-path-bash.sh).overrideAttrs (oldAttrs: {
    passthru.tests = {
      inherit (tests) test-bash;
    };
  });
  patchSourcetimePathCsh = (makeSetupHook
    {
      name = "patch-sourcetime-path-csh";
      substitutions = {
        sed = "${gnused}/bin/sed";
      };
      meta = with lib; {
        descriptions = "Setup-hook to inject source-time PATH prefix to a Csh script";
        maintainers = with maintainers; [ ShamrockLee ];
      };
    } ./patch-sourcetime-path-csh.sh).overrideAttrs (oldAttrs: {
    passthru.tests = {
      inherit (tests) test-csh;
    };
  });
  patchSourcetimePathFish = (makeSetupHook
    {
      name = "patch-sourcetime-path-fish";
      meta = with lib; {
        descriptions = "Setup-hook to inject source-time PATH prefix to a Fish script";
        maintainers = with maintainers; [ ShamrockLee ];
      };
    } ./patch-sourcetime-path-fish.sh).overrideAttrs (oldAttrs: {
    passthru.tests = {
      inherit (tests) test-fish;
    };
  });
  patchSourcetimePathPosix = (makeSetupHook
    {
      name = "patch-sourcetime-path-posix";
      substitutions = {
        sed = "${gnused}/bin/sed";
      };
      meta = with lib; {
        descriptions = "Setup-hook to inject source-time PATH prefix to a POSIX shell script";
        maintainers = with maintainers; [ ShamrockLee ];
      };
    } ./patch-sourcetime-path-posix.sh).overrideAttrs (oldAttrs: {
    passthru.tests = {
      inherit (tests) test-posix;
    };
  });
}
