{ lib
, stdenv
, fetchFromGitHub
, cmake
, help2man
, include-what-you-use # optional optimize tool
, python3
, curl
, xrootd
, enableDoc ? true
, enableMan ? true
}:

let
  python-with-sphinx = python3.withPackages (ps: with ps; [ sphinx ]);
in
stdenv.mkDerivation rec {
  pname = "eos";
  version = "5.0.13";

  src = fetchFromGitHub {
    owner = "cern-eos";
    repo = "eos";
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-pcAMvVe5Natb6UqpTtvGwkTa3Umv5T1JPABtMNaRhj0=";
  };

  outputs = [ "out" ]
  ++ lib.optional enableDoc "doc"
  ++ lib.optional enableMan "man";

  nativeBuildInputs = [
    cmake
    include-what-you-use
    python-with-sphinx
  ]
  ++ lib.optional enableDoc python-with-sphinx
  ++ lib.optional enableMan help2man;

  buildInputs = [
    curl
    xrootd
  ];

  postPatch = ''
    sed -i '/^\s*EOS_GetUidGid/d' CMakeLists.txt
  '';
  
  meta = with lib; {
    description = "An multi-PB storage software solution for CERN LHC";
    homepage = "https://github.com/cern-eos/eos";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ ShamrockLee ];
  };
}
