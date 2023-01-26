{ lib
, fetchFromGitLab
, perlPackages
, clamav
}:

perlPackages.buildPerlPackage rec {
  pname = "clamtk";
  version = "6.14";

  src = fetchFromGitLab {
    owner = "dave_m";
    repo = "clamtk";
    rev = "v${version}";
    hash = "sha256-FRoB/0JkWqTKRCmQIFQ/ZyTLvKZIwL7hGSQqIMZ52ZM=";
  };

  buildInputs = [
    clamav
  ]
  ++ (with perlPackages; [
    Gtk3
    JSON
    LocaleGettext
    LWP # a.k.a. libwww
    LWPProtocolHttps
    TextCSV
  ])
  ;

  meta = with lib; {
    description = "A graphical frontend of ClamAV, the virus scanner";
    homepage = "https://gitlab.com/dave_m/clamtk";
    license = licenses.artistic2;
    platforms = platforms.all;
    maintainers = with maintainers; [ ShamrockLee ];
  };
}
