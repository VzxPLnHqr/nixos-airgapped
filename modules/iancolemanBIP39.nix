{ lib, pkgs, config, ... }:
let
  iancolemanBip39Page = pkgs.stdenv.mkDerivation rec {
    name = "iancolemanBip39-page";
    /*src = builtins.fetchTarball {
      url = "https://github.com/iancoleman/bip39/archive/refs/tags/0.5.6.tar.gz";
      sha256 = "sha256:1b90icr6i7d4zjf71dhq63fwd89yjmv44xgwg2sqh6znb8zc12wf";
    };*/
    src = builtins.fetchurl {
      url = "https://github.com/iancoleman/bip39/releases/download/0.5.6/bip39-standalone.html";
      sha256 = "sha256:129b03505824879b8a4429576e3de6951c8599644c1afcaae80840f79237695a";
    };
    unpackPhase = ":"; # nothing to unapck since it is a single file
    buildPhase = ''
      cp $src index.html
      cp -a . $out
    '';
  };
in {

  # host the bip39 tool offline
  services.nginx = {
    enable = true;
    virtualHosts."iancoleman-bip39.local" = {
      root = "${iancolemanBip39Page}";
    };
  };

  networking.extraHosts = "127.0.0.1 iancoleman-bip39.local";


}