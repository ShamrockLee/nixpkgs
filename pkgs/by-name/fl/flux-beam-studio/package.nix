{ lib
, yarn2nix-moretea
, fetchFromGitHub
, fetchYarnDeps
}:

yarn2nix-moretea.mkYarnPackage rec {
  pname = "flux-beam-studio";
  version = "1.2.6b1";

  src = fetchFromGitHub {
    owner = "flux3dp";
    repo = "beam-studio";
    rev = "v${version}";
    hash = "sha256-KeHENO0pH50kAx6YiujlBuBF2iU+H3qh1nozE8Qoxkg=";
  };

  # The project is licensed under GNU AGPL v3.
  # We cannot legally place package.json and yarn.lock inside the Nixpkgs source.
  packageJSON = builtins.fetchurl {
    url = passthru.packageJSONUrl;
    sha256 = "sha256-b3hB55JrgzZ8VlSEPSOMvt+oazgkMVvJ6P6RZERv/BA=";
  };

  yarnLock = builtins.fetchurl {
    url = passthru.yarnLockUrl;
    sha256 = "sha256-v1Q5Ity/ngfbxoyVtlZFdSfDjPOqFGI30iD3JNQUJRI=";
  };

  offlineCache = fetchYarnDeps {
    name = "${pname}-${lib.substring 0 8 (builtins.hashFile "sha256" yarnLock)}-offline-cache";
    inherit yarnLock;
    hash = "sha256-mF1i0kNUICohpCGOFM5bAekzNTWAwIvB4Pa4jaT/0aw=";
  };

  passthru = {
    packageJSONUrl = "https://github.com/${src.owner}/${src.repo}/raw/${src.rev}/package.json";
    yarnLockUrl = "https://github.com/${src.owner}/${src.repo}/raw/${src.rev}/yarn.lock";
  };

  meta = with lib; {
    description = "Software for Beambox Series";
    homepage = "https://github.com/flux3dp/beam-studio";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ShamrockLee ];
    mainProgram = "beam-studio";
    platforms = platforms.all;
  };
}
