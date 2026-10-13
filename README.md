# nixos-in-podman

A full NixOS system in a Podman container, rebuildable in place with
`nixos-rebuild switch`.

## Prerequisites

- Nix with flakes enabled
- Podman

## Build the image

```console
nix build .#nixos-in-podman-image
```

This produces `./result`, a tarball loadable by Podman.

## Load and run

```console
podman load -i result
podman run --privileged --name nixos-in-podman nixos-in-podman:local
```

## Rebuild inside the container

Copy the flake sources (`flake.nix`, `flake.lock`, `configuration.nix`) into the
container (or bind-mount them), then run:

```console
nixos-rebuild switch --flake .#nixos-in-podman
```

This requires network access to fetch nixpkgs and the binary cache.

## Restarting

In-container changes live in the container's writable layer, so use
`podman stop` + `podman start` (or `podman restart`) to keep them:

```console
podman restart nixos-in-podman
```

`podman rm` + `podman run` discards those changes and starts fresh from the
image.

## Configuration

All NixOS options live in [`configuration.nix`](./configuration.nix). The image
name, tag and target system are set at the top of [`flake.nix`](./flake.nix).

---

All documentation, comments, and `description` fields in this repository are
AI-generated.
