{ pkgs, lib, ... }: {
  system.stateVersion = "26.05";

  # Disables things that only make sense on real hardware: udev/device
  # management, kernel and module loading, power management, audit, LVM, the
  # bootloader, etc.
  boot.isContainer = true;

  # These are provided by the container runtime (podman), so NixOS must not
  # manage them itself:
  #
  # - hostname: podman sets it (--name/--hostname) and bind-mounts /etc/hostname.
  #   Leaving it empty prevents NixOS from generating /etc/hostname, which would
  #   otherwise conflict with podman's bind mount ("could not create symlink").
  #
  # - /etc/hosts: podman bind-mounts its own copy. NixOS would otherwise try to
  #   symlink its generated version into place and fail.
  #
  # - DHCP: podman's network backend (pasta) already assigns the IP address and
  #   routes. dhcpcd would find no interface to manage and is useless here.
  #
  # - resolvconf: NixOS's resolvconf service would rewrite /etc/resolv.conf from
  #   /run/resolvconf. Since nothing registers nameservers (dhcpcd is off), it
  #   would overwrite podman's bind-mounted resolv.conf with an empty one and
  #   break DNS resolution.
  networking.hostName = "";
  environment.etc."hosts".enable = false;
  networking.useDHCP = false;
  networking.resolvconf.enable = false;

  # systemd ships default mount units for debugfs and tracefs. In a rootless
  # container (user namespace) these filesystems cannot be mounted: they are not
  # FS_USERNS_MOUNT and require CAP_SYS_ADMIN in the *initial* user namespace,
  # which rootless containers do not have.
  #
  # (nixpkgs already excludes sys-kernel-config.mount for containers, but not
  # these two.)
  systemd.suppressedSystemUnits = [
    "sys-kernel-debug.mount"
    "sys-kernel-tracing.mount"
  ];

  # On a physical machine, installBootLoader installs GRUB/systemd-boot. In a
  # container the "bootloader" is just the /init entrypoint, so this updates
  # /init to point at the new toplevel. Without it, `nixos-rebuild switch` would
  # switch the running services but /init would still point at the old system,
  # and restarting the container would boot the old generation again.
  system.build.installBootLoader = pkgs.writeShellScript "install-container-init" ''
    ${lib.escapeShellArg pkgs.coreutils}/bin/ln -fs "$1/init" /init
  '';
}
