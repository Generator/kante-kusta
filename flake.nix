{
  description = "kante-kusta - KuantoKusta CLI (musl static)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          # pure API (rustls) — no wreq/boringssl
          packages = with pkgs; [
            pkg-config
          ];
          shellHook = ''
            echo "kante-kusta devShell (pure API) — ${system}"
            echo "  cargo  $(cargo --version 2>/dev/null || true)"
            echo "  rustc  $(rustc --version 2>/dev/null || true)"
            echo ""
            echo "Build (glibc): cargo build --release"
            echo "Build (musl):  cargo build --release --target ${if system == "aarch64-linux" then "aarch64-unknown-linux-musl" else "x86_64-unknown-linux-musl"}"
          '';
        };

        devShells.musl = pkgs.mkShell {
          # musl static — pure API
          packages = with pkgs; [
            pkg-config
            musl
          ];
          shellHook = ''
            echo "kante-kusta devShell musl (pure API) — ${system}"
            rustup target list --installed 2>/dev/null | grep -q ${if system == "aarch64-linux" then "aarch64-unknown-linux-musl" else "x86_64-unknown-linux-musl"} || rustup target add ${if system == "aarch64-linux" then "aarch64-unknown-linux-musl" else "x86_64-unknown-linux-musl"} 2>/dev/null || true
            echo "  cargo  $(cargo --version 2>/dev/null || true)"
            echo "  rustc  $(rustc --version 2>/dev/null || true)"
            echo "  musl   $(ls /nix/store/*musl-1.2*/bin/musl-gcc 2>/dev/null | head -n1 || echo musl)"
            echo ""
            echo "Build (musl): cargo build --release --target ${if system == "aarch64-linux" then "aarch64-unknown-linux-musl" else "x86_64-unknown-linux-musl"}"
          '';
        };
      });
}
