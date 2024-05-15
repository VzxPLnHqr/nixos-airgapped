{ lib, pkgs, config, codex32-website, ... }: {

	services.nginx = {
    enable = true;
    virtualHosts."codex32.offline" = {
        root = "${codex32-website.packages.x86_64-linux.codex32-website}/www";
    };
  };

  networking.extraHosts = "127.0.0.1 codex32.offline";

}