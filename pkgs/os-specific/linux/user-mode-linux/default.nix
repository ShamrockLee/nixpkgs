{ lib
, runCommand
, kernel
, packagesFor ? null
, self
, ...
}@args:

let
  removePrePost = phaseName: lib.replaceStrings [
    "runHook pre${phaseName}\n"
    "runHook post${phaseName}\n"
  ] [ "" "" ];
  kernel' = kernel.override (previousArgs: {
    kernelArch = "um";
    kernelSubArch = kernel.configfile.kernelArch;
  } // removeAttrs args [
    "kernel" "packagesFor" "self"
  ]);
in
kernel'.overrideAttrs (finalAttrs: previousAttrs: {
  pname = "user-mode-" + previousAttrs.pname or "linux";
  outputs = lib.unique ([ "bin" ] ++ previousAttrs.outputs or [ "out" ]);
  makeFlags = previousAttrs.makeFlags or [ ] ++ kernel'.extraMakeFlags;
  preInstall = (removePrePost "Install" previousAttrs.installPhase or "");
  installPhase = "";
  passthru = previousAttrs.passthru or { } // {
    tests = previousAttrs.passthru.tests or { } // {
      binary-existence = runCommand "user-mode-linux-test-binary-existence" { } ''
        for NAME in linux vmlinux; do
          [[ -e ${lib.escapeShellArg "${finalAttrs.finalPackage}"}"/bin/$NAME" ]]
        done
      '';
    };
  } // lib.optionalAttrs (packagesFor != null) {
    baseKernel = kernel;
    # Use `self` for consistent `<pkg>.override` interface
    linuxPackages = lib.recurseIntoAttrs ((packagesFor self).extend (final: previous: {
      kernel = previous.kernel.override {
        self = final.kernel;
      };
      user-mode-linux = final.kernel;
    }));
  };
  meta = previousAttrs.meta or { } // {
    mainProgram = "linux";
  };
})
