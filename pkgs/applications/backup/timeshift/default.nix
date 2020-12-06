{ symlinkJoin, lib
, timeshift-unwrapped, rsync, coreutils, mount, umount, psmisc, cron
, enableBtrfs ? true, btrfs-progs ? null, enableGrub ? true
, grubPackage ? grub2_full, grub2_full ? null }:

assert enableBtrfs -> (btrfs-progs != null);
assert enableGrub -> (grubPackage != null);

symlinkJoin {
  inherit (timeshift-unwrapped) name;
  paths = [ timeshift-unwrapped ];
  allowSubstitute = true;

  propagatedBuildInputs = [ timeshift-unwrapped ]
    ++ [ rsync coreutils mount umount psmisc cron ]
    ++ lib.lists.optional enableBtrfs [ btrfs-progs ]
    ++ lib.lists.optional enableGrub [ grubPackage ];

  meta = timeshift-unwrapped.meta // {
    description = timeshift-unwrapped.descriptionCommon
      + " (with runtime deps)";
    longDescription = timeshift-unwrapped.longDescriptionCommon + ''
      This package comes with runtime dependencies of command utilities provided by rsync, coreutils, mount, umount, psmisc, cron and (optionally) btrfs.
      If you want to use the commands provided by the system, override the inputs arguments with nul or use timeshift-unwrapped instead
    '';
  };
}
