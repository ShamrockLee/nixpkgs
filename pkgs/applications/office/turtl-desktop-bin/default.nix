{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, gcc-unwrapped
, glib
, openssl
, libsodium
, alsa-lib
, cups
, libffi
, gnome2
, nss
, xorg
}:
stdenv.mkDerivation rec {
  pname = "turtl-desktop-bin";
  version = "0.7.2.5";

  src = if stdenv.hostPlatform.isDarwin
  then (fetchurl {
    url = "https://github.com/turtl/desktop/releases/download/v${version}/turtl-${version}-osx.zip";
    sha256 = "06bv1c2zr49l8ac6lj7d1621ffshr1cbaxvcs4fiwhqhd41dasi6";
    })
  else let
    getTurtlBinUrl = (version: is32bit:
      "https://github.com/turtl/desktop/releases/download/v${version}/turtl-${version}-linux" + (if is32bit then "32" else "64") + ".tar.bz2");
  in if stdenv.hostPlatform.is32bit
  then (fetchurl {
    url = getTurtlBinUrl version true;
    sha256 = "0v5d58dkxc9b6gjny24x35m3inw4nznfvm08g93gxl8d7v41s4r4";
  })
  else (fetchurl {
    url = getTurtlBinUrl version false;
    sha256 = "10df6ifldpq8j66s016mb2cdd2fvix510grfbdxx1k1yg32b4s1w";
  });

  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [
      autoPatchelfHook
      gcc-unwrapped.lib # libstdc++.so.6
      openssl # official dep of turtl-core-rs
      libsodium # official dep of turtl-core-rs
      alsa-lib # libasound.so.2
      cups.lib # libcups.so.2
      libffi # libffmpeg.so
      glib
      gnome2.gtk
      gnome2.libgnome
      nss # libnss3.so, libnssutil3.so
      xorg.libXdamage # libXdamage.so.1
      xorg.libXtst # libXtst.so.6
      xorg.libXScrnSaver # libXss.so.1
    ];

  installPhase = ''
    installScript="./install.sh"

    patchShebangs "$installScript"

    mkdir -p "$out/bin"
    sed -i -r 's|^(.*\s+)?GLOBAL_PATH=/.*|\1GLOBAL_PATH='"$out"'/bin|' "$installScript"
    sed -i -r 's|^(.*\s+)?LOCAL_PATH=.*|\1LOCAL_PATH='"$out"'/bin|' "$installScript"
    mkdir -p "$out/share"
    sed -i -r 's|^(.*\s+)?GLOBAL_SHARE=/.*|\1GLOBAL_SHARE='"$out"'/share|' "$installScript"
    sed -i -r 's|^(.*\s+)?LOCAL_SHARE=.*|\1LOCAL_SHARE='"$out"'/share|' "$installScript"
    mkdir -p "$out/etc"
    substituteInPlace "$installScript" --replace "~/.config" "$out/etc"

    "$installScript" "$out/bin"

    sed -i -r 's|Icon=.*|Icon='"$out/share/icons/hicolor/128x128/apps/turtl.png"'|' "$out/share/applications/turtl.desktop"
  '';

  meta = with lib; {
    description = "Desktop app of Turtl, the secure, collaborative notebook.";
    homepage = "https://turtlapp.com/";
    license = licenses.gpl3;
    platforms = platforms.unix;
    maintainers = with maintainers; [ ShamrockLee ];
  };
}