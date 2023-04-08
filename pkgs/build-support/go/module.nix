{ lib
, stdenv
, cacert
, git
, go
}:

# Documentation about attributes can be found in comment blocks
# begin with `ATTRIBUTES:`

let
  # This helper function moves "special attributes" into `passthru.__onetimeAttrs`
  # to prevent string coertion.
  # One use case here is `overrideModAttrs`
  collectOnetimeAttrs = names: attrs:
    (removeAttrs attrs names) // {
      passthru = attrs.passthru or { } // {
        __onetimeAttrs = builtins.foldl'
          (attrsCollected: name:
            attrsCollected // lib.optionalAttrs (builtins.elem name names) {
              "${name}" = attrs.${name};
            })
          { }
          (builtins.attrNames attrs);
      };
    };
in
rattrs:
# Upgrade and overriding:
#
# Prefetch the vendorHash:
# ```sh
# nix-prefetch -E "{ sha256 }: ((import ./. { }).my-package.overrideAttrs (_: { vendorHash = sha256; })).go-modules"
# ```
#
# Override the vendorHash:
# ```nix
# my-package.overrideAttrs (_: {
#   src = fetchFromGitHub { ... };
#   vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA88224466BA=";
# })
# ```
#
# Note that overrideModAttrs and mod*Phase are merely syntax sugar for packaging,
# and is not available when overriding. Override go-modules directly instead:
# ```nix
# my-package.overrideAttrs (finalAttrs: previousAttrs: {
#   go-modules = previousAttrs.go-modules.overrideAttrs (finalModAttrs: prevModAttrs: {
#     configurePhase = ...;
#     preBuild = ...;
#     buildPhase = ...;
#     installPhase = ...;
#   });
# })
# ```

((stdenv.mkDerivation (as:
  collectOnetimeAttrs
    [
      # ATTRIBUTES: These attributes won't be passed down to later overlays

      # Function with style `(previousAttrs: { ... })`.
      # It is syntax sugar to override go-modules,
      # equivalent to `go-modules.overrideAttrs overrideModAttrs`
      "overrideModAttrs"

      # Syntax sugar to manually specify the corresponding phases
      # of the `go-modules` sub-derivation.
      "modConfigurePhase"
      "modBuildPhase"
      "modeInstallPhase"
    ]
    (if lib.isFunction rattrs then rattrs as else rattrs)
)).overrideAttrs (finalAttrs: previousAttrs:
  let
    hasAnyVendorHash = finalAttrs.vendorHash != null && finalAttrs.vendorHash != "_unset" || finalAttrs.vendorSha256 != null && finalAttrs.vendorSha256 != "_unset";
    inherit (previousAttrs.passthru) __onetimeAttrs;
  in
  {
    # ATTRIBUTES:
    # These attributes will be given default values
    # when not set previously

    # Go linker flags, passed to go via -ldflags
    ldflags = previousAttrs.ldflags or [ ];

    # Go tags, passed to go via -tag
    tags = previousAttrs.tags or [ ];

    # path to go.mod and go.sum directory
    modRoot = previousAttrs.modRoot or "./";

    # vendorHash is the SRI hash of the vendored dependencies
    #
    # if vendorHash is null, then we won't fetch any dependencies and
    # rely on the vendor folder within the source.
    vendorHash = previousAttrs.vendorHash or "_unset";

    # same as vendorHash, but outputHashAlgo is hardcoded to sha256
    # so regular base32 sha256 hashes work
    vendorSha256 = previousAttrs.vendorSha256 or "_unset";

    # Whether to delete the vendor folder supplied with the source.
    deleteVendor = previousAttrs.deleteVendor or false;
    # Whether to fetch (go mod download) and proxy the vendor directory.
    # This is useful if your code depends on c code and go mod tidy does not
    # include the needed sources to build or if any dependency has case-insensitive
    # conflicts which will produce platform dependant `vendorHash` checksums.
    proxyVendor = previousAttrs.proxyVendor or false;

    # We want parallel builds by default
    enableParallelBuilding = previousAttrs.enableParallelBuilding or true;

    # Do not enable this without good reason
    # IE: programs coupled with the compiler
    allowGoReference = previousAttrs.allowGoReference or false;

    CGO_ENABLED = previousAttrs.CGO_ENABLED or go.CGO_ENABLED;

    # Default to run the tests
    doCheck = previousAttrs.doCheck or true;

    # These phases will be shared with the 'go-modules` sub-derivation
    # so we give them default values if not specified.
    preUnpack = previousAttrs.preUnpack or null;
    unpackPhase = previousAttrs.unapckPhase or null;
    postUnpack = previousAttrs.postUnpack or null;
    sourceRoot = previousAttrs.sourceRoot or null;
    prePatch = previousAttrs.prePatch or null;
    patches = previousAttrs.patches or [ ];
    patchFlags = previousAttrs.patchFlags or [ ];
    patchPhase = previousAttrs.patchPhase or null;
    postPatch = previousAttrs.postPatch or null;
    preBuild = previousAttrs.preBuild or null;
    postBuild = previousAttrs.postBuild or null;

    # `configurePhase`, `buildPhase` and `checkPhase` attributes can be set,
    # but their default values are the implementation of this builder,
    # so leave them unset unless you need to overwrite them.
    #
    # If you would like to use `stdenv.mkDerivation`-provided phases,
    # set the corresponding phases to `null`.


    # ATTRIBUTES:
    # These attributes must not be set.
    # Here we feed them dummy values for later assertions.

    goPackagePath = previousAttrs.goPackagePath or "";
    buildFlags = previousAttrs.buildFlags or "";
    buildFlagsArray = previousAttrs.buildFlagsArray or "";


    # ATTRIBUTES:
    # These attributes will be appended:
    # `buildInputs` `passthru` `meta`

    # Other attributes set below will be directly overriten by this builder.
    # Use overrideAttrs if you really want to modify them.

    # End of the ATTRIBUTES documentation blocks


    # Fixed output derivation containing Go modules
    go-modules = if (!hasAnyVendorHash) then "" else
    (stdenv.mkDerivation (finalModAttrs: {

      nativeBuildInputs = finalAttrs.nativeBuildInputs or [ ] ++ [ cacert git go ];

      inherit (finalAttrs) src;

      inherit (finalAttrs) prePatch patches patchFlags postPatch preBuild postBuild sourceRoot;

      inherit (go) GOOS GOARCH;
      GO111MODULE = "on";

      impureEnvVars = lib.fetchers.proxyImpureEnvVars ++ [
        "GIT_PROXY_COMMAND"
        "SOCKS_SERVER"
        "GOPROXY"
      ];

      configurePhase = __onetimeAttrs.modConfigurePhase or ''
        runHook preConfigure
        export GOCACHE=$TMPDIR/go-cache
        export GOPATH="$TMPDIR/go"
        cd "${finalAttrs.modRoot}"
        runHook postConfigure
      '';

      buildPhase = __onetimeAttrs.modBuildPhase or (''
        runHook preBuild
      '' + lib.optionalString finalAttrs.deleteVendor ''
        if [ ! -d vendor ]; then
          echo "vendor folder does not exist, 'deleteVendor' is not needed"
          exit 10
        else
          rm -rf vendor
        fi
      '' + ''
        if [ -d vendor ]; then
          echo "vendor folder exists, please set 'vendorHash = null;' or 'vendorSha256 = null;' in your expression"
          exit 10
        fi

        ${if finalAttrs.proxyVendor then ''
          mkdir -p "''${GOPATH}/pkg/mod/cache/download"
          go mod download
        '' else ''
          if (( "''${NIX_DEBUG:-0}" >= 1 )); then
            goModVendorFlags+=(-v)
          fi
          go mod vendor "''${goModVendorFlags[@]}"
        ''}

        mkdir -p vendor

        runHook postBuild
      '');

      installPhase = __onetimeAttrs.modInstallPhase or ''
        runHook preInstall

        ${if finalAttrs.proxyVendor then ''
          rm -rf "''${GOPATH}/pkg/mod/cache/download/sumdb"
          cp -r --reflink=auto "''${GOPATH}/pkg/mod/cache/download" $out
        '' else ''
          cp -r --reflink=auto vendor $out
        ''}

        if ! [ "$(ls -A $out)" ]; then
          echo "vendor folder is empty, please set 'vendorHash = null;' or 'vendorSha256 = null;' in your expression"
          exit 10
        fi

        runHook postInstall
      '';

      dontFixup = true;

      outputHashMode = "recursive";
      outputHashAlgo = if finalAttrs.vendorSha256 != "_unset" then "sha256" else null;
      outputHash = if finalAttrs.vendorHash != "_unset" then finalAttrs.vendorHash else finalAttrs.vendorSha256;
    }
    // (if (previousAttrs ? pname && previousAttrs.pname != "" && previousAttrs ? version) then {
      pname = "go-modules-${finalAttrs.pname}";
      inherit (finalAttrs) version;
    } else {
      name = "go-modules-${finalAttrs.name}";
    }))).overrideAttrs __onetimeAttrs.overrideModAttrs or (_: { });

    nativeBuildInputs = [ go ] ++ previousAttrs.nativeBuildInputs or [ ];

    inherit (go) GOOS GOARCH;

    GO111MODULE = "on";
    GOFLAGS = lib.optionals (!finalAttrs.proxyVendor) [ "-mod=vendor" ] ++ lib.optionals (!finalAttrs.allowGoReference) [ "-trimpath" ];

    configurePhase = previousAttrs.configurePhase or (''
      runHook preConfigure

      export GOCACHE=$TMPDIR/go-cache
      export GOPATH="$TMPDIR/go"
      export GOPROXY=off
      export GOSUMDB=off
      cd "$modRoot"
    '' + lib.optionalString hasAnyVendorHash ''
      ${if finalAttrs.proxyVendor then ''
        export GOPROXY=file://${finalAttrs.go-modules}
      '' else ''
        rm -rf vendor
        cp -r --reflink=auto ${finalAttrs.go-modules} vendor
      ''}
    '' + ''

      # currently pie is only enabled by default in pkgsMusl
      # this will respect the `hardening{Disable,Enable}` flags if set
      if [[ $NIX_HARDENING_ENABLE =~ "pie" ]]; then
        export GOFLAGS="-buildmode=pie $GOFLAGS"
      fi

      runHook postConfigure
    '');

    buildPhase = previousAttrs.buildPhase or (''
      runHook preBuild

      exclude='\(/_\|examples\|Godeps\|testdata'
      if [[ -n "$excludedPackages" ]]; then
        IFS=' ' read -r -a excludedArr <<<$excludedPackages
        printf -v excludedAlternates '%s\\|' "''${excludedArr[@]}"
        excludedAlternates=''${excludedAlternates%\\|} # drop final \| added by printf
        exclude+='\|'"$excludedAlternates"
      fi
      exclude+='\)'

      buildGoDir() {
        local cmd="$1" dir="$2"

        . $TMPDIR/buildFlagsArray

        declare -a flags
        flags+=($buildFlags "''${buildFlagsArray[@]}")
        flags+=(''${tags:+-tags=${lib.concatStringsSep "," finalAttrs.tags}})
        flags+=(''${ldflags:+-ldflags="$ldflags"})
        flags+=("-p" "$NIX_BUILD_CORES")

        if [ "$cmd" = "test" ]; then
          flags+=(-vet=off)
          flags+=($checkFlags)
        fi

        local OUT
        if ! OUT="$(go $cmd "''${flags[@]}" $dir 2>&1)"; then
          if ! echo "$OUT" | grep -qE '(no( buildable| non-test)?|build constraints exclude all) Go (source )?files'; then
            echo "$OUT" >&2
            return 1
          fi
        fi
        if [ -n "$OUT" ]; then
          echo "$OUT" >&2
        fi
        return 0
      }

      getGoDirs() {
        local type;
        type="$1"
        if [ -n "$subPackages" ]; then
          echo "$subPackages" | sed "s,\(^\| \),\1./,g"
        else
          find . -type f -name \*$type.go -exec dirname {} \; | grep -v "/vendor/" | sort --unique | grep -v "$exclude"
        fi
      }

      if (( "''${NIX_DEBUG:-0}" >= 1 )); then
        buildFlagsArray+=(-x)
      fi

      if [ ''${#buildFlagsArray[@]} -ne 0 ]; then
        declare -p buildFlagsArray > $TMPDIR/buildFlagsArray
      else
        touch $TMPDIR/buildFlagsArray
      fi
      if [ -z "$enableParallelBuilding" ]; then
          export NIX_BUILD_CORES=1
      fi
      for pkg in $(getGoDirs ""); do
        echo "Building subPackage $pkg"
        buildGoDir install "$pkg"
      done
    '' + lib.optionalString (stdenv.hostPlatform != stdenv.buildPlatform) ''
      # normalize cross-compiled builds w.r.t. native builds
      (
        dir=$GOPATH/bin/${go.GOOS}_${go.GOARCH}
        if [[ -n "$(shopt -s nullglob; echo $dir/*)" ]]; then
          mv $dir/* $dir/..
        fi
        if [[ -d $dir ]]; then
          rmdir $dir
        fi
      )
    '' + ''
      runHook postBuild
    '');

    checkPhase = previousAttrs.checkPhase or ''
      runHook preCheck

      # We do not set trimpath for tests, in case they reference test assets
      export GOFLAGS=''${GOFLAGS//-trimpath/}

      for pkg in $(getGoDirs test); do
        buildGoDir test "$pkg"
      done

      runHook postCheck
    '';

    installPhase = previousAttrs.installPhase or ''
      runHook preInstall

      mkdir -p $out
      dir="$GOPATH/bin"
      [ -e "$dir" ] && cp -r $dir $out

      runHook postInstall
    '';

    strictDeps = true;

    disallowedReferences = lib.optional (!finalAttrs.allowGoReference) go;

    passthru = (removeAttrs previousAttrs.passthru [ "__onetimeAttrs" ]) // {
      inherit go;
    };

    meta = {
      # Add default meta information
      platforms = go.meta.platforms or lib.platforms.all;
    } // previousAttrs.meta or { };
  }

  # Assertions
)).overrideAttrs (finalAttrs: previousAttrs: {
  go-modules =
    # Assert that either vendorHash or vendorSha256 is set.
    assert finalAttrs.vendorHash == "_unset" && finalAttrs.vendorSha256 == "_unset" -> throw
      "both `vendorHash` and `vendorSha256` set. only one can be set.";
    assert finalAttrs.goPackagePath != "" -> throw
      "`goPackagePath` is not needed with `buildGoModule`";
    lib.warnIf (finalAttrs.buildFlags != "" || finalAttrs.buildFlagsArray != "")
      "Use the `ldflags` and/or `tags` attributes instead of `buildFlags`/`buildFlagsArray`"
      previousAttrs.go-modules;
})
