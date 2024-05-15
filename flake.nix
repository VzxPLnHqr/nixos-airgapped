{
  description = "NixOS Airgapped";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex32-website.url = "github:vzxplnhqr/volvelle-website?ref=nix-flake";
  };

  outputs = inputs@{ self, nixpkgs, nixos-generators, codex32-website }: {


    nixosModules.nixos-airgapped = {pkgs, config, codex32-website, ...}: {

            imports = [ ./configuration.nix ];

            # Let 'nixos-version --json' know about the Git revision
            # of this flake.
            system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
    };

    # build a vm by running `nixos-rebuild build-vm --flake .#nixos-airgapped`
    # the vm can be started by running `./result/bin/run-...`
    nixosConfigurations.nixos-airgapped = nixpkgs.lib.nixosSystem {
      specialArgs = inputs;
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };

    # build the iso by running `nix build .#nixos-airgapped-iso`
    packages.x86_64-linux.nixos-airgapped-iso = nixos-generators.nixosGenerate {
      specialArgs = inputs;
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];

      # see different formats here: https://github.com/nix-community/nixos-generators
      # for nixos bootable installer ISO change to "install-iso"
      format = "iso";
    };
    
    # by default we build the .iso (`nix build .#nixos-airgapped-iso)
    packages.x86_64-linux.default = self.packages.x86_64-linux.nixos-airgapped-iso;

  };
}
