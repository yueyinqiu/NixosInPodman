# nixos-in-podman

A full NixOS system in a Podman container, rebuildable in place with
`nixos-rebuild switch`.

## Use the published image

No Nix needed — just Podman:

```console
podman run --privileged --name nixos-in-podman ghcr.io/yueyinqiu/nixos-in-podman:latest
```

Tags:

- `latest` — the newest build from `main`.
- `<commit sha>` — a specific commit.

## Build from source

Requires Nix with flakes enabled.

```console
nix build .#nixos-in-podman-image
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
