# nixos-in-podman

A template for a full NixOS system in a Podman container, rebuildable in place
with `nixos-rebuild switch`.

## Use as a template

1. Click **Use this template** on GitHub to create your own repository.
2. Edit `configuration.nix` to your liking. The base is minimal, so add anything
   you need in the container (e.g. `git`, `openssh`).
3. If you publish an image, update the repository path in
   `.github/workflows/publish.yml`; if not, delete that workflow.
4. Build and run (requires Nix with flakes enabled and Podman):

```console
nix build .#nixos-in-podman-image
podman load -i result
podman run --privileged --name nixos-in-podman nixos-in-podman:local
```

## Rebuild inside the container

Get a shell inside the container:

```console
podman exec -it nixos-in-podman /run/current-system/sw/bin/bash -l
```

Then clone your repository and switch to it:

```console
nix --extra-experimental-features 'nix-command flakes' run nixpkgs#git -- clone <your-repository-url>
cd <repository>
nixos-rebuild switch --flake .#nixos-in-podman
```

This requires network access to fetch nixpkgs and the binary cache.

## Published image

The author publishes builds to `ghcr.io/yueyinqiu/nixos-in-podman` (tags:
`latest` and the commit sha). To run one without building:

```console
podman run --privileged --name nixos-in-podman ghcr.io/yueyinqiu/nixos-in-podman:latest
```

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
