{ symlinkJoin
, unconfigured-package
, customConfigJsTarget ? null
}:

let
  pname = "turtl-js";
  version = unconfigured-package.version;
  configJsDefaultPath =
    "${unconfigured-package.outPath}/lib/node_modules/turtl-js/config/config.js.default";
  configJsTarget =
    if customConfigJsTarget == null then configJsDefaultPath else customConfigJsTarget;
in
symlinkJoin {
  name = "${pname}-${version}";
  paths = [ unconfigured-package ];
  postBuild = ''
    ln -s "${configJsTarget}" "$out/lib/node_modules/turtl-js/config/config.js"
  '';
}