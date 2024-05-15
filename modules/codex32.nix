{ lib, pkgs, config, codex32-website, ... }: {

  # host the codex32 website offline
  #  THIS IS BROKEN
  #   for some strange reason, nginx does not serve the site up properly
  #   however, manually running the following *does* seem to work:
  #
  #   cd /nix/store/18aakaqqgi2a4dam0zq80v6gkmb1r41k-codex32-website-1.0.0/www
  #   python3 webserver.py
  #   # now the site is accessible at http://localhost:9000
  #
  #  but why does the below simple nginx site serving out of the same directory
  #  not work? WHY!!!? 

  services.nginx = {
    enable = true;
    virtualHosts."codex32.offline" = {
      root = "${codex32-website}/www";
    };
  };

  networking.extraHosts = "127.0.0.1 codex32.offline";

}