{
  description = "A full NixOS system in a Podman container, rebuildable in place.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      name = "nixos-in-podman";
      tag = "local";
      system = "x86_64-linux";
      os = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [ ./configuration.nix ];
      };
    in
    {
      nixosConfigurations.${name} = os;

      packages.${system}."${name}-image" = os.pkgs.dockerTools.buildImageWithNixDb {
        name = name;
        tag = tag;
        copyToRoot = os.config.system.build.toplevel;
        config = {
          Entrypoint = [ "/init" ];
        };
        # The toplevel's /etc points into the read-only store (the environment.etc
        # symlink farm). A container needs a real, writable /etc instead:
        # podman bind-mounts /etc/hosts, /etc/resolv.conf and /etc/hostname into it,
        # and NixOS's activation script regenerates /etc at boot. So drop the store
        # /etc and recreate it empty.
        extraCommands = ''
          chmod -R u+w etc
          rm -rf etc
          mkdir -p etc
        '';
      };
    };
}
