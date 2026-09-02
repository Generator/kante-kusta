{
  description = "kante-kusta - KuantoKusta CLI (musl static)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          # pure API (rustls) — no wreq/boringssl
          packages = with pkgs; [
            pkg-config
          ];
          shellHook = ''
            echo "kante-kusta devShell (pure API) — x86_64-linux"
            echo "  cargo  $(cargo --version 2>/dev/null || true)"
            echo "  rustc  $(rustc --version 2>/dev/null || true)"
            echo ""
            echo "Build (glibc): cargo build --release"
            echo "Build (musl):  cargo build --release --target x86_64-unknown-linux-musl"
          '';
        };

        devShells.musl = pkgs.mkShell {
          # musl static — pure API
          packages = with pkgs; [
            pkg-config
            musl
          ];
          shellHook = ''
            echo "kante-kusta devShell musl (pure API) — x86_64-linux"
            rustup target list --installed 2>/dev/null | grep -q x86_64-unknown-linux-musl || rustup target add x86_64-unknown-linux-musl 2>/dev/null || true
            echo "  cargo  $(cargo --version 2>/dev/null || true)"
            echo "  rustc  $(rustc --version 2>/dev/null || true)"
            echo "  musl   $(ls /nix/store/*musl-1.2*/bin/musl-gcc 2>/dev/null | head -n1 || echo musl)"
            echo ""
            echo "Build (musl): cargo build --release --target x86_64-unknown-linux-musl"
          '';
        };
      });
}
