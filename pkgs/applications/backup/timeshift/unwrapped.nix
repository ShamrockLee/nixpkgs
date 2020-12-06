{ stdenv, fetchFromGitHub,
wrapGAppsHook, pkg-config, vala, which, gettext,
vte, xapp ? cinnamon.xapps, cinnamon, gtk3, libgee, json-glib
, bash }:

stdenv.mkDerivation rec {
  pname = "timeshift";
  version = "20.11.1";

  src = fetchFromGitHub {
    owner = "teejee2008";
    repo = pname;
    rev = "v${version}";
    sha256 = "0hkq31s14iyl2r3m5jw23lxl617f4nidfdigagmx1z0lkvcdpxnw";
  };

  postPatch = ''
    find ./src -mindepth 1 -name "*.vala" -type f -exec sed -i 's/"\/sbin\/blkid"/"blkid"/g' {} \;
    mkdir -p $out
    substituteInPlace ./src/makefile \
        --replace "SHELL=/bin/bash" "SHELL=${bash}" \
        --replace "prefix=/usr" "prefix=$out" \
        --replace "sysconfdir=/etc" "sysconfdir=$out/etc"
  '';

  buildInputs = [ vte xapp gtk3 libgee json-glib ];
  nativeBuildInputs = [ wrapGAppsHook vala pkg-config which gettext ];
  propagatedBuildInputs = [ bash ];

  doCheck = true;

  passthru = {
    descriptionCommon = "A system restore tool for Linux";
    longDescriptionCommon = ''
      TimeShift creates filesystem snapshots using rsync+hardlinks or BTRFS snapshots.
      Snapshots can be restored using TimeShift installed on the system or from Live CD or USB.
      The main purpose of this package is to restore the TimeShift images of distros *other than* NixOS. NixOS comes with sophisticated ways to rollback and switch generations, and its own way to manage bootloaders and system cron jobs. To use against other distros, this package can be installed on a working NixOS on USB stick or another partition, or on the target system or other distros through Nix package manager.
    '';
  };

  meta = with stdenv.lib; {
    description = passthru.descriptionCommon + " (without runtime deps)";
    longDescription = passthru.longDescriptionCommon + ''
      This package comes without runtime dependencies. Command utilities such as
      rsync (rsync)
      blkid, df, cp, rm, touch, ln, sync (coreutils)
      mount (mount)
      umount (umount)
      fuser (psmisc)
      crontab (cron) (anacron may also be needed for other package manager)
      If you want to take snapshots with BTRFS,
      commands provided by btrfs-progs are also needed.
      Be sure that these commands are available for timeshift, or used the package timeshift instead.
    '';
    homepage = "https://github.com/teejee2008/timeshift";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ShamrockLee ];
  };
}
