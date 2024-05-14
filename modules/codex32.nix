{ lib, pkgs, config, ... }:
let
  codex32-website = pkgs.rustPlatform.buildRustPackage rec {
    name = "codex32-website";
    src = pkgs.fetchFromGitHub {
      owner = "apoelstra";
      repo = "volvelle-website";
      rev = "main";
      hash = "sha256-ZkIFqSE/blcOfqiehY/Wt6HCc2dcLrOTDH7hM72M/n8=";
    };
    sourceRoot = "source/volvelle-wasm";
    cargoSha256 = "beUS0vVAH3nKlQll7cn51U+m8QLKiZcWgh56tC1BDKw=";
    nativeBuildInputs = with pkgs; [ 
      git rustc cargo gcc llvmPackages.bintools wasm-pack 
    ];
    buildPhase = ''
      echo "STARTING BUILD"
      # mkdir -p target/pkg
      # wasm-pack build --out-dir target/pkg --target no-modules
      # cargo test
      wasm-pack build --target no-modules
      echo "FINISHED BUILD"
    '';
  };
in {

  # host the bip39 tool offline
  services.nginx = {
    enable = true;
    virtualHosts."codex32.offline" = {
      root = "${codex32-website}";
    };
  };

  networking.extraHosts = "127.0.0.1 codex32.offline";


}