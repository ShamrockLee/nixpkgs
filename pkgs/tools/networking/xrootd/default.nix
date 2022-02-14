{ lib
, stdenv
, fetchFromGitHub
, cmake
, libkrb5
, libuuid
, libxml2
, openssl
, systemd
, zlib
}:

stdenv.mkDerivation rec {
  pname = "xrootd";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "xrootd";
    repo = "xrootd";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "A2yUz2KhuRBoo5lMpZwPLNCJlYQXqsZSBR+Knj+gWAk=";
  };

  outputs = [ "bin" "out" "dev" "man" ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libkrb5
    libuuid
    libxml2
    openssl
    zlib
  ]
  ++ lib.optional stdenv.isLinux systemd;

  preConfigure = ''
    patchShebangs genversion.sh
  '';

  meta = with lib; {
    description = "High performance, scalable fault tolerant data access";
    homepage = "https://xrootd.slac.stanford.edu";
    license = licenses.lgpl3Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ ShamrockLee ];
  };
}
