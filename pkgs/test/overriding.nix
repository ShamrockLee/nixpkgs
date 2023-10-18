{ lib, pkgs, stdenvNoCC }:

let
  tests =
    let
      inherit (pkgs.python3Packages) pillow xpybutil;
      applyOverridePythonAttrs = p: p.overridePythonAttrs (_: {dontWrapPythonPrograms = true; });
      revertOverridePythonAttrs = p: p.overridePythonAttrs (_: {dontWrapPythonPrograms = false; });
      getIsPythonAttrsOverriden = p: !lib.hasInfix "wrapPythonPrograms" p.postFixup;
      xpybutil1 = applyOverridePythonAttrs xpybutil;
      pillow1 = applyOverridePythonAttrs pillow;
      applyOverridePillow = p: p.override { pillow = pillow1; };
      getIsOverridenPillow = p: builtins.any (p': lib.hasPrefix "pillow" p'.pname && getIsPythonAttrsOverriden p') p.propagatedBuildInputs;
      xpybutil2 = applyOverridePillow xpybutil;
      xpybutil31 = applyOverridePillow xpybutil1;
      xpybutil32 = applyOverridePythonAttrs xpybutil2;
    in
    [
      ({
        name = "overridePythonAttrs";
        expr = getIsPythonAttrsOverriden xpybutil1;
        expected = true;
      })
      ({
        name = "overridePythonAttrs-nested";
        expr = revertOverridePythonAttrs xpybutil1 == xpybutil;
        expected = true;
      })
      ({
        name = "override-pythonPackage";
        expr = getIsOverridenPillow xpybutil2;
        expected = true;
      })
      ({
        name = "overridePythonAttrs-override";
        expr = builtins.any (p: lib.hasPrefix "pillow" p.pname && getIsPythonAttrsOverriden p) xpybutil31.propagatedBuildInputs;
        expected = true;
      })
      ({
        name = "overridePythonAttrs-overrid-commutative";
        expr = xpybutil31 == xpybutil32;
        expected = true;
      })
      ({
        name = "repeatedOverrides-pname";
        expr = repeatedOverrides.pname == "a-better-hello-with-blackjack";
        expected = true;
      })
      ({
        name = "repeatedOverrides-entangled-pname";
        expr = repeatedOverrides.entangled.pname == "a-better-figlet-with-blackjack";
        expected = true;
      })
      ({
        name = "overriding-using-only-attrset";
        expr = (pkgs.hello.overrideAttrs { pname = "hello-overriden"; }).pname == "hello-overriden";
        expected = true;
      })
      ({
        name = "overriding-using-only-attrset-no-final-attrs";
        expr = ((stdenvNoCC.mkDerivation { pname = "hello-no-final-attrs"; }).overrideAttrs { pname = "hello-no-final-attrs-overridden"; }).pname == "hello-no-final-attrs-overridden";
        expected = true;
      })
    ];

  addEntangled = origOverrideAttrs: f:
    origOverrideAttrs (
      lib.composeExtensions f (self: super: {
        passthru = super.passthru // {
          entangled = super.passthru.entangled.overrideAttrs f;
          overrideAttrs = addEntangled self.overrideAttrs;
        };
      })
    );

  entangle = pkg1: pkg2: pkg1.overrideAttrs (self: super: {
    passthru = super.passthru // {
      entangled = pkg2;
      overrideAttrs = addEntangled self.overrideAttrs;
    };
  });

  example = entangle pkgs.hello pkgs.figlet;

  overrides1 = example.overrideAttrs (_: super: { pname = "a-better-${super.pname}"; });

  repeatedOverrides = overrides1.overrideAttrs (_: super: { pname = "${super.pname}-with-blackjack"; });
in

stdenvNoCC.mkDerivation {
  name = "test-overriding";
  passthru = { inherit tests; };
  buildCommand = ''
    touch $out
  '' + lib.concatMapStringsSep "\n" (t: "([[ ${lib.boolToString t.expr} == ${lib.boolToString t.expected} ]] && echo '${t.name} success') || (echo '${t.name} fail' && exit 1)") tests;
}
