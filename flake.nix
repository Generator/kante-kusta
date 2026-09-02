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
          # glibc + wreq (default) — no musl, avoids _LARGEFILE64/mmap64 conflict
          packages = with pkgs; [
            pkg-config
            cmake
            go
            perl
            clang
            llvm
            llvmPackages.libclang
            lld
          ];
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          CLANG_PATH = "${pkgs.clang}/bin/clang";
          shellHook = ''
            echo "kante-kusta devShell default (glibc, wreq) — x86_64-linux"
            rustup target list --installed 2>/dev/null | grep -q x86_64-unknown-linux-gnu || true
            echo "  cargo  $(cargo --version 2>/dev/null || true)"
            echo "  rustc  $(rustc --version 2>/dev/null || true)"
            echo "  cmake  $(cmake --version 2>/dev/null | head -n1 || true)"
            echo "  clang  $(clang --version 2>/dev/null | head -n1 || true)"
            echo ""
            echo "Build (glibc, wreq):       cargo build --release"
            echo "Build (musl, pure rustls): nix develop .#musl --command cargo build --release --target x86_64-unknown-linux-musl --no-default-features"
          '';
        };

        devShells.musl = pkgs.mkShell {
          # musl static — pure rustls (--no-default-features), no libclang
          packages = with pkgs; [
            pkg-config
            musl
            cmake
            go
            perl
          ];
          shellHook = ''
            echo "kante-kusta devShell musl (static, rustls) — x86_64-linux"
            rustup target list --installed 2>/dev/null | grep -q x86_64-unknown-linux-musl || rustup target add x86_64-unknown-linux-musl 2>/dev/null || true
            echo "  cargo  $(cargo --version 2>/dev/null || true)"
            echo "  rustc  $(rustc --version 2>/dev/null || true)"
            echo "  cmake  $(cmake --version 2>/dev/null | head -n1 || true)"
            echo "  musl   $(ls /nix/store/*musl-1.2*/bin/musl-gcc 2>/dev/null | head -n1 || echo musl)"
            echo ""
            echo "Build (musl, pure rustls): cargo build --release --target x86_64-unknown-linux-musl --no-default-features"
          '';
        };
      });
}
