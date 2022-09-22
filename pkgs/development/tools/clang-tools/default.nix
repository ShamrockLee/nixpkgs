{ lib
, stdenv
, lndir ? xorg.lndir
, xorg
, llvmPackages
, python3
}:

let
  unwrapped = llvmPackages.clang-unwrapped;

in
stdenv.mkDerivation {

  outputs = [ "out" "python" ];

  nativeBuildInputs = [
    lndir
  ];

  inherit unwrapped;

  pname = "clang-tools";
  version = lib.getVersion unwrapped;
  dontUnpack = true;
  clang = llvmPackages.clang;

  unwrapped_python = unwrapped.python;
  pythonInterpreter = python3.interpreter;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    # Link and wrap binaries
    for tool in $unwrapped/bin/clang-*; do
      tool=$(basename "$tool")

      # Compilers have their own derivation, no need to include them here:
      if [[ $tool == "clang-cl" || $tool == "clang-cpp" ]]; then
        continue
      fi

      # Clang's derivation produces a lot of binaries, but the tools we are
      # interested in follow the `clang-something` naming convention - except
      # for clang-$version (e.g. clang-13), which is the compiler again:
      if [[ ! $tool =~ ^clang\-[a-zA-Z_\-]+$ ]]; then
        continue
      fi

      ln -s $out/bin/clangd $out/bin/$tool
    done

    if [[ -z "$(ls -A $out/bin)" ]]; then
      echo "Found no binaries - maybe their location or naming convention changed?"
      exit 1
    fi

    substituteAll ${./wrapper} $out/bin/clangd
    chmod +x $out/bin/clangd

    # Link and wrap python scripts (copy-free replacement to patchShebangs)
    mkdir -p $python/bin
    substituteAll ${./wrapper-python} $python/bin/.python3-script-wrapper
    chmod +x $python/bin/.python3-script-wrapper

    for tool in $unwrapped_python/bin/*; do
      ln -s "$python/bin/.python3-script-wrapper" "$python/bin/$(basename "$tool")"
    done

    # Python script executables may depend on modules stored in "''${clang-unwrapped.python}/share"
    mkdir -p $python/share
    lndir -silent "$unwrapped_python/share" "$python/share"

    runHook postInstall
  '';

  meta = unwrapped.meta // {
    description = "Standalone command line tools for C++ development";
    maintainers = with lib.maintainers; [ patryk27 ShamrockLee ];
    outputsToInstall = [ "out" "python" ];
  };
}
