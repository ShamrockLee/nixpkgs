{ stdenv
, fetchFromGitHub
#, symlinkJoin
, enableGAppsWrapping ? true
, wrapGAppsHook ? null
, readline
, ncurses #? curses
, zlib
, gsl
, openmp
, graphicsmagick #? imagemagick
# wx-3.1 introduce breaking changes of API.
# The work is in progress at gnudatalanguage/gdl issue #831
# Before that, use wxGTK30
, wxWidgets ? wxGTK30 , wxGTK30 ? null # wxGTK31, wxGTK30, wxGTK29
, netcdf
, hdf4
, hdf5-cpp
, fftw, fftwFloat, fftwLongDouble
, proj
, shapelib
, expat
, libraryMPI ? mpich # openmpi
, mpich ? null
, pythonInterpreter
, udunits
, eigen
, pslib # a C library for PostScript
, eccodes
, glpk
# dependent librearies CMake asked for
, libpng
, plplot
, libtiff
, libgeotiff
#, szip # for hdf4 and hdf5
, libjpeg # for hdf4 and hdf5
, x11
, libtirpc
# native build inputs for the compiler
, cmake
, pkgconfig
, enableWX ? true
, enableXWin ? true
}:

assert enableWX -> wxWidgets != null;
assert enableXWin -> x11 != null;

stdenv.mkDerivation rec {
  pname = "gnudatalanguage";
  version = "1.0.0-rc.3";

  src = fetchFromGitHub {
    owner = pname;
    repo = "gdl";
    rev = "v${version}";
    sha256 = "1kym7fcnxad5slk41cvpwrqxdy62sdy3yx08ndf948jjx7rwx50c";
  };

  buildInputs = [
    readline
    ncurses
    zlib
    gsl
    openmp
    graphicsmagick
    netcdf
    hdf4
    hdf5-cpp
    fftw fftwFloat fftwLongDouble
    proj
    shapelib
    expat
    libraryMPI
    udunits
    eigen
    pslib
    eccodes
    glpk
    libpng
    plplot
    libtiff
    libgeotiff
    #szip
    libjpeg
    libtirpc
  ];

  propagatedBuildInputs = [
    (pythonInterpreter.withPackages (ps: with ps; [ numpy ]))
  ]
  ++ stdenv.lib.lists.optional enableXWin [ x11 ]
  ++ stdenv.lib.lists.optional enableWX [ wxWidgets ]
  ++ stdenv.lib.lists.optional enableGAppsWrapping [ wrapGAppsHook ];

  nativeBuildInputs = [ cmake pkgconfig ];

  cmakeFlags = [
    #"-DHDFDIR=${symlinkJoin {
    #  name = "dhdfLibInc";
    #  paths = [ hdf4.out hdf4.dev ];
    #}}"
    "-DHDF=OFF" #@TODO: Fix "HDF4 libraries were not found." complaint by CMake
  ]
  ++ stdenv.lib.lists.optional (!enableWX) [ "-DWXWIDGETS=OFF" ]
  ++ stdenv.lib.lists.optional (!enableXWin) [ "-DX11=OFF" ];

  #@TODO: Why are all the test not running?
  #       They pass when running against the compiled binary.
  doCheck = false;

  meta = with stdenv.lib; {
    description = "A free incremental compiler compatible with IDL (Interactive Data Language)";
    longDescription = ''
      GDL (GNU Data Language) is a free/libre/open source incremental compiler compatible with IDL (Interactive Data Language) and to some extent with PV-WAVE.
      Together with its library routines it serves as a tool for data analysis and visualization in such disciplines as astronomy, geosciences and medical imaging.
      As GDL is aimed as a drop-in replacement for IDL.
    '';
    homepage = "https://github.com/gnudatalanguage/gdl";
    #changelog = "";
    license = licenses.gpl2;
    maintainers = with maintainers; [ ShamrockLee ];
    platforms = platforms.all;
  };
}
