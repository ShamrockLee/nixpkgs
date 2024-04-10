{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "zsd";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "j-keck";
    repo = "zsd";
    rev = "v${version}";
    hash = "sha256-V4AKUMNGriWdu6wUsnbJ4ynvZBQVND96ffA3I3so8nY=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-9/E6yH6m4mioeuntA87jbgh6aMZfclJy3IAb/+P490Y=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Cli tool to find older versions of a given file in your zfs snapshots";
    homepage = "https://github.com/j-keck/zsd";
    license = licenses.mit;
    maintainers = with maintainers; [ ShamrockLee ];
    mainProgram = "zsd";
  };
}
